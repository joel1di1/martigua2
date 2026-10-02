# frozen_string_literal: true

namespace :ffhb do
  task sync: :environment do
    Championship.where(season: Season.current).where.not(ffhb_key: nil).map(&:async_ffhb_sync!)
  end

  desc 'Rewrite a renamed FFHB competition slug on a championship and its matches. ' \
       'Usage: rake "ffhb:fix_competition_slug[641,u18m-championnat-92-75-33470]" (DRY_RUN=1 to preview)'
  task :fix_competition_slug, %i[championship_id new_slug] => :environment do |_task, args|
    championship = Championship.find(args.fetch(:championship_id))
    new_slug = args.fetch(:new_slug)
    dry_run = ENV['DRY_RUN'].present?

    saison, type, old_slug, phase_id, pool_id = championship.ffhb_key.to_s.split
    abort "Championship #{championship.id}: unexpected ffhb_key #{championship.ffhb_key.inspect}" if pool_id.blank?

    next puts("Championship #{championship.id} already uses #{new_slug}") if old_slug == new_slug

    # Make sure FFHB really serves the pool under the new slug before touching data.
    pool = FfhbService.instance.fetch_pool_details(new_slug, pool_id)
    abort "FFHB pool mismatch: #{pool['url_competition']} / #{pool['selected_poule']['ext_pouleId']}" \
      unless pool['url_competition'] == new_slug && pool['selected_poule']['ext_pouleId'].to_s == pool_id

    matches = championship.matches.where('ffhb_key LIKE ?', "#{old_slug} %")
    puts "Championship #{championship.id}: #{old_slug} -> #{new_slug} (#{matches.count} matches)"
    next puts('DRY_RUN: no change made') if dry_run

    ActiveRecord::Base.transaction do
      championship.update!(ffhb_key: [saison, type, new_slug, phase_id, pool_id].join(' '))
      matches.find_each { |match| match.update!(ffhb_key: match.ffhb_key.sub(/\A#{Regexp.escape(old_slug)} /, "#{new_slug} ")) }
    end

    championship.ffhb_sync!
    puts "Done. #{championship.matches.reload.count} matches"
  end
end
