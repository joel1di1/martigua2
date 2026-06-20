# frozen_string_literal: true

class FdmParserService
  LICENCE_PATTERN = /\d{13}/

  def initialize(fdm_code)
    @fdm_code = fdm_code
  end

  def self.pdf_url_for(fdm_code)
    chars = fdm_code.chars
    "https://media-ffhb-fdm.ffhandball.fr/fdm/#{chars[0]}/#{chars[1]}/#{chars[2]}/#{chars[3]}/#{fdm_code}.pdf"
  end

  def parse
    pdf_content = download_pdf
    return [] if pdf_content.nil?

    reader = PDF::Reader.new(StringIO.new(pdf_content))
    page_text = reader.pages.first.text
    parse_page(page_text)
  rescue PDF::Reader::MalformedPDFError, PDF::Reader::UnsupportedFeatureError => e
    Rails.logger.warn("FdmParserService: Failed to parse PDF for #{@fdm_code}: #{e.message}")
    []
  end

  private

  def download_pdf
    url = self.class.pdf_url_for(@fdm_code)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      response.body
    else
      Rails.logger.warn("FdmParserService: Failed to download PDF for #{@fdm_code}: HTTP #{response.code}")
      nil
    end
  end

  def parse_page(text)
    lines = text.lines.map(&:rstrip)
    players = []

    header_positions = nil

    lines.each do |line|
      if header_positions.nil? && line.include?('Buts') && line.include?('Tirs') && line.include?('Arrets')
        header_positions = extract_header_positions(line)
        next
      end

      if header_positions && line.match?(LICENCE_PATTERN) && line.exclude?('Officiel')
        player = parse_player_line(line, header_positions)
        players << player if player
      end

      header_positions = nil if line.include?('Officiel Resp') || line.include?('Officiel A')
    end

    players
  end

  def extract_header_positions(line)
    {
      buts: line.index('Buts'),
      sept_m: line.index('7m'),
      tirs: line.index('Tirs'),
      arrets: line.index('Arrets'),
      av: line.index('Av.'),
      deux_min: line.index("2'"),
      dis: line.index('Dis')
    }
  end

  def parse_player_line(line, positions)
    licence_match = line.match(/(#{LICENCE_PATTERN})/)
    return nil if licence_match.nil?

    licence = licence_match[1]
    before_licence = line[0...licence_match.begin(0)]

    name_match = before_licence.match(/(\d{1,3})\s{2,}([A-ZÀ-Ÿ]{2,}.+?)\s*$/)
    return nil if name_match.nil?

    jersey_number = name_match[1].to_i
    full_name = name_match[2].strip

    captain_region = before_licence[0...name_match.begin(1)]
    captain = captain_region.match?(/\bX\b/)

    last_name, first_name = split_name(full_name)

    {
      player_id: licence,
      first_name: first_name,
      last_name: last_name,
      jersey_number: jersey_number,
      captain: captain,
      goals: extract_stat(line, positions[:buts], positions[:sept_m]),
      seven_meters: extract_stat(line, positions[:sept_m], positions[:tirs]),
      shots: extract_stat(line, positions[:tirs], positions[:arrets]),
      saves: extract_stat(line, positions[:arrets], positions[:av]),
      warnings: extract_marker(line, positions[:av], positions[:deux_min]),
      two_minutes: extract_stat(line, positions[:deux_min], positions[:dis]),
      disqualifications: extract_stat(line, positions[:dis], nil)
    }
  end

  def split_name(full_name)
    match = full_name.match(/^([A-ZÀ-Ÿ\s-]+?)\s+([a-zà-ÿ].*)$/)
    if match
      [match[1].strip, match[2].strip]
    else
      [full_name, '']
    end
  end

  def extract_stat(line, start_pos, end_pos)
    return 0 if start_pos.nil?

    segment = if end_pos
                line[start_pos...end_pos]
              else
                line[start_pos..]
              end
    return 0 if segment.nil?

    number = segment.strip.scan(/\d+/).first
    number ? number.to_i : 0
  end

  def extract_marker(line, start_pos, end_pos)
    return 0 if start_pos.nil?

    segment = if end_pos
                line[start_pos...end_pos]
              else
                line[start_pos..]
              end
    return 0 if segment.nil?

    segment.include?('X') ? 1 : 0
  end
end
