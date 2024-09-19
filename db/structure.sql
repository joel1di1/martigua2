SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: absences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.absences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    start_at date,
    end_at date,
    name character varying,
    comment character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: absences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.absences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: absences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.absences_id_seq OWNED BY public.absences.id;


--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_admin_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_admin_comments (
    id integer NOT NULL,
    namespace character varying(255),
    body text,
    resource_id character varying(255) NOT NULL,
    resource_type character varying(255) NOT NULL,
    author_id integer,
    author_type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_admin_comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_admin_comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_admin_comments_id_seq OWNED BY public.active_admin_comments.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: admin_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: admin_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admin_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admin_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admin_users_id_seq OWNED BY public.admin_users.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: blocked_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocked_addresses (
    id bigint NOT NULL,
    email character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: blocked_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocked_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocked_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocked_addresses_id_seq OWNED BY public.blocked_addresses.id;


--
-- Name: burns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.burns (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    championship_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: burns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.burns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: burns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.burns_id_seq OWNED BY public.burns.id;


--
-- Name: calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendars (
    id bigint NOT NULL,
    season_id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: calendars_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.calendars_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendars_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.calendars_id_seq OWNED BY public.calendars.id;


--
-- Name: championship_group_championships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.championship_group_championships (
    id bigint NOT NULL,
    championship_id bigint NOT NULL,
    championship_group_id bigint NOT NULL,
    index integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: championship_group_championships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.championship_group_championships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championship_group_championships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.championship_group_championships_id_seq OWNED BY public.championship_group_championships.id;


--
-- Name: championship_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.championship_groups (
    id bigint NOT NULL,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: championship_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.championship_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championship_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.championship_groups_id_seq OWNED BY public.championship_groups.id;


--
-- Name: championships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.championships (
    id integer NOT NULL,
    season_id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    calendar_id bigint,
    ffhb_key character varying
);


--
-- Name: championships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.championships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: championships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.championships_id_seq OWNED BY public.championships.id;


--
-- Name: channels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.channels (
    id bigint NOT NULL,
    section_id bigint NOT NULL,
    name character varying,
    private boolean,
    system boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.channels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.channels_id_seq OWNED BY public.channels.id;


--
-- Name: club_admin_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.club_admin_roles (
    id integer NOT NULL,
    club_id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: club_admin_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.club_admin_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: club_admin_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.club_admin_roles_id_seq OWNED BY public.club_admin_roles.id;


--
-- Name: clubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clubs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clubs_id_seq OWNED BY public.clubs.id;


--
-- Name: days; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.days (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    period_start_date date,
    period_end_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    calendar_id bigint,
    selection_hidden boolean DEFAULT false NOT NULL
);


--
-- Name: days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.days_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.days_id_seq OWNED BY public.days.id;


--
-- Name: duty_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.duty_tasks (
    id bigint NOT NULL,
    name character varying NOT NULL,
    user_id bigint NOT NULL,
    realised_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    weight integer DEFAULT 0 NOT NULL,
    key character varying,
    club_id bigint NOT NULL
);


--
-- Name: duty_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.duty_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: duty_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.duty_tasks_id_seq OWNED BY public.duty_tasks.id;


--
-- Name: enrolled_team_championships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enrolled_team_championships (
    id integer NOT NULL,
    team_id integer,
    championship_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    enrolled_name character varying,
    ffhb_team_id character varying
);


--
-- Name: enrolled_team_championships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enrolled_team_championships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enrolled_team_championships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enrolled_team_championships_id_seq OWNED BY public.enrolled_team_championships.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    section_id integer,
    description character varying(255),
    color character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    system boolean DEFAULT false NOT NULL,
    role character varying(255),
    season_id integer
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: groups_trainings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_trainings (
    training_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: groups_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups_users (
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


--
-- Name: locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ffhb_id character varying
);


--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: match_availabilities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_availabilities (
    id integer NOT NULL,
    match_id integer NOT NULL,
    user_id integer NOT NULL,
    available boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: match_availabilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_availabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_availabilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_availabilities_id_seq OWNED BY public.match_availabilities.id;


--
-- Name: match_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_invitations (
    id bigint NOT NULL,
    match_id bigint NOT NULL,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: match_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_invitations_id_seq OWNED BY public.match_invitations.id;


--
-- Name: match_selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.match_selections (
    id integer NOT NULL,
    match_id integer NOT NULL,
    team_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: match_selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.match_selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.match_selections_id_seq OWNED BY public.match_selections.id;


--
-- Name: matches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.matches (
    id integer NOT NULL,
    championship_id integer,
    local_team_id integer,
    visitor_team_id integer,
    start_datetime timestamp without time zone,
    end_datetime timestamp without time zone,
    prevision_period_start date,
    prevision_period_end date,
    local_score integer,
    visitor_score integer,
    location_id integer,
    meeting_datetime timestamp without time zone,
    meeting_location character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    day_id integer,
    shared_calendar_id character varying,
    shared_calendar_url character varying,
    ffhb_key character varying
);


--
-- Name: matches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.matches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.matches_id_seq OWNED BY public.matches.id;


--
-- Name: math_trainer_answer_fights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_answer_fights (
    id bigint NOT NULL,
    answer_id bigint NOT NULL,
    fight_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_answer_fights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_answer_fights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_answer_fights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_answer_fights_id_seq OWNED BY public.math_trainer_answer_fights.id;


--
-- Name: math_trainer_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_answers (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    problem_id bigint NOT NULL,
    text character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    correct boolean,
    card_session_id bigint
);


--
-- Name: math_trainer_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_answers_id_seq OWNED BY public.math_trainer_answers.id;


--
-- Name: math_trainer_answers_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_answers_sessions (
    id bigint NOT NULL,
    answer_id bigint NOT NULL,
    time_session_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_answers_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_answers_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_answers_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_answers_sessions_id_seq OWNED BY public.math_trainer_answers_sessions.id;


--
-- Name: math_trainer_ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_card_session_problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_card_session_problems (
    id bigint NOT NULL,
    problem_id bigint NOT NULL,
    card_session_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_card_session_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_card_session_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_card_session_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_card_session_problems_id_seq OWNED BY public.math_trainer_card_session_problems.id;


--
-- Name: math_trainer_card_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_card_sessions (
    id bigint NOT NULL,
    title character varying,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_card_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_card_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_card_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_card_sessions_id_seq OWNED BY public.math_trainer_card_sessions.id;


--
-- Name: math_trainer_fight_opponents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_fight_opponents (
    id bigint NOT NULL,
    name character varying,
    health integer,
    speed integer,
    color_rot integer,
    operation_types jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_fight_opponents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_fight_opponents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_fight_opponents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_fight_opponents_id_seq OWNED BY public.math_trainer_fight_opponents.id;


--
-- Name: math_trainer_fights; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_fights (
    id bigint NOT NULL,
    fight_opponent_id bigint NOT NULL,
    user_id bigint NOT NULL,
    remaining_player_health integer,
    remaining_opponent_health integer,
    round_duration integer,
    name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_fights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_fights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_fights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_fights_id_seq OWNED BY public.math_trainer_fights.id;


--
-- Name: math_trainer_problems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_problems (
    id bigint NOT NULL,
    type character varying,
    number_1 integer,
    number_2 integer,
    hole_position integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: math_trainer_problems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_problems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_problems_id_seq OWNED BY public.math_trainer_problems.id;


--
-- Name: math_trainer_schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_schema_migrations (
    version character varying NOT NULL
);


--
-- Name: math_trainer_time_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_time_sessions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    minutes integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    operation_types jsonb DEFAULT '{}'::jsonb,
    shuffle_hole_position boolean DEFAULT false
);


--
-- Name: math_trainer_time_sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_time_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_time_sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_time_sessions_id_seq OWNED BY public.math_trainer_time_sessions.id;


--
-- Name: math_trainer_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.math_trainer_users (
    id bigint NOT NULL,
    "DeviseCreateUsers" character varying,
    email character varying DEFAULT ''::character varying,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    uuid uuid
);


--
-- Name: math_trainer_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.math_trainer_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: math_trainer_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.math_trainer_users_id_seq OWNED BY public.math_trainer_users.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.messages (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    parent_message_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: participations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.participations (
    id integer NOT NULL,
    user_id integer NOT NULL,
    section_id integer NOT NULL,
    season_id integer NOT NULL,
    role character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: participations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.participations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: participations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.participations_id_seq OWNED BY public.participations.id;


--
-- Name: passeport_availability_checks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passeport_availability_checks (
    id bigint NOT NULL,
    ended_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    key character varying,
    "idQdt" integer,
    "idSit" integer,
    "dateDeb" character varying,
    "dateFin" character varying,
    params jsonb,
    response_code character varying,
    response_body character varying
);


--
-- Name: passeport_availability_checks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.passeport_availability_checks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: passeport_availability_checks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.passeport_availability_checks_id_seq OWNED BY public.passeport_availability_checks.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scrapped_rankings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scrapped_rankings (
    id bigint NOT NULL,
    scrapped_content text,
    championship_number character varying,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: scrapped_rankings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.scrapped_rankings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scrapped_rankings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.scrapped_rankings_id_seq OWNED BY public.scrapped_rankings.id;


--
-- Name: seasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.seasons (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- Name: section_user_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.section_user_invitations (
    id integer NOT NULL,
    section_id integer NOT NULL,
    email character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    nickname character varying(255),
    phone_number character varying(255),
    roles character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: section_user_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.section_user_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: section_user_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.section_user_invitations_id_seq OWNED BY public.section_user_invitations.id;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections (
    id integer NOT NULL,
    club_id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: sections_trainings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sections_trainings (
    training_id integer NOT NULL,
    section_id integer NOT NULL
);


--
-- Name: selections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.selections (
    id integer NOT NULL,
    user_id integer NOT NULL,
    match_id integer NOT NULL,
    team_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: selections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.selections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: selections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.selections_id_seq OWNED BY public.selections.id;


--
-- Name: sms_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sms_notifications (
    id integer NOT NULL,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    section_id integer
);


--
-- Name: sms_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sms_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sms_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sms_notifications_id_seq OWNED BY public.sms_notifications.id;


--
-- Name: starburst_announcement_views; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.starburst_announcement_views (
    id bigint NOT NULL,
    user_id integer,
    announcement_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: starburst_announcement_views_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.starburst_announcement_views_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: starburst_announcement_views_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.starburst_announcement_views_id_seq OWNED BY public.starburst_announcement_views.id;


--
-- Name: starburst_announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.starburst_announcements (
    id bigint NOT NULL,
    title text,
    body text,
    start_delivering_at timestamp without time zone,
    stop_delivering_at timestamp without time zone,
    limit_to_users text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category text
);


--
-- Name: starburst_announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.starburst_announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: starburst_announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.starburst_announcements_id_seq OWNED BY public.starburst_announcements.id;


--
-- Name: team_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.team_sections (
    id integer NOT NULL,
    team_id integer NOT NULL,
    section_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: team_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.team_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.team_sections_id_seq OWNED BY public.team_sections.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    club_id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: training_invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_invitations (
    id integer NOT NULL,
    training_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: training_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.training_invitations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.training_invitations_id_seq OWNED BY public.training_invitations.id;


--
-- Name: training_presences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.training_presences (
    id integer NOT NULL,
    user_id integer NOT NULL,
    training_id integer NOT NULL,
    is_present boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    presence_validated boolean
);


--
-- Name: training_presences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.training_presences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: training_presences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.training_presences_id_seq OWNED BY public.training_presences.id;


--
-- Name: trainings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trainings (
    id integer NOT NULL,
    start_datetime timestamp without time zone NOT NULL,
    end_datetime timestamp without time zone,
    location_id integer,
    cancelled boolean DEFAULT false,
    cancel_reason text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: trainings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.trainings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trainings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.trainings_id_seq OWNED BY public.trainings.id;


--
-- Name: user_championship_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_championship_stats (
    id bigint NOT NULL,
    user_id bigint,
    championship_id bigint NOT NULL,
    match_played integer,
    goals integer,
    saves integer,
    goal_average integer,
    save_average integer,
    player_id character varying,
    first_name character varying,
    last_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_championship_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_championship_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_championship_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_championship_stats_id_seq OWNED BY public.user_championship_stats.id;


--
-- Name: user_channel_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_channel_messages (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    read boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_channel_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_channel_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_channel_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_channel_messages_id_seq OWNED BY public.user_channel_messages.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    first_name character varying(255),
    last_name character varying(255),
    nickname character varying(255),
    phone_number character varying(255),
    authentication_token character varying(255),
    invitation_token character varying(255),
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying(255),
    invitations_count integer DEFAULT 0
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: webpush_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.webpush_subscriptions (
    id bigint NOT NULL,
    endpoint character varying,
    p256dh_key character varying,
    auth_key character varying,
    user_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: webpush_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.webpush_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webpush_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.webpush_subscriptions_id_seq OWNED BY public.webpush_subscriptions.id;


--
-- Name: absences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences ALTER COLUMN id SET DEFAULT nextval('public.absences_id_seq'::regclass);


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: blocked_addresses id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_addresses ALTER COLUMN id SET DEFAULT nextval('public.blocked_addresses_id_seq'::regclass);


--
-- Name: burns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.burns ALTER COLUMN id SET DEFAULT nextval('public.burns_id_seq'::regclass);


--
-- Name: calendars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars ALTER COLUMN id SET DEFAULT nextval('public.calendars_id_seq'::regclass);


--
-- Name: championship_group_championships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_group_championships ALTER COLUMN id SET DEFAULT nextval('public.championship_group_championships_id_seq'::regclass);


--
-- Name: championship_groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_groups ALTER COLUMN id SET DEFAULT nextval('public.championship_groups_id_seq'::regclass);


--
-- Name: championships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships ALTER COLUMN id SET DEFAULT nextval('public.championships_id_seq'::regclass);


--
-- Name: channels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels ALTER COLUMN id SET DEFAULT nextval('public.channels_id_seq'::regclass);


--
-- Name: club_admin_roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_admin_roles ALTER COLUMN id SET DEFAULT nextval('public.club_admin_roles_id_seq'::regclass);


--
-- Name: clubs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clubs ALTER COLUMN id SET DEFAULT nextval('public.clubs_id_seq'::regclass);


--
-- Name: days id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.days ALTER COLUMN id SET DEFAULT nextval('public.days_id_seq'::regclass);


--
-- Name: duty_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_tasks ALTER COLUMN id SET DEFAULT nextval('public.duty_tasks_id_seq'::regclass);


--
-- Name: enrolled_team_championships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrolled_team_championships ALTER COLUMN id SET DEFAULT nextval('public.enrolled_team_championships_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: match_availabilities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_availabilities ALTER COLUMN id SET DEFAULT nextval('public.match_availabilities_id_seq'::regclass);


--
-- Name: match_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_invitations ALTER COLUMN id SET DEFAULT nextval('public.match_invitations_id_seq'::regclass);


--
-- Name: match_selections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_selections ALTER COLUMN id SET DEFAULT nextval('public.match_selections_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: math_trainer_answer_fights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answer_fights ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_answer_fights_id_seq'::regclass);


--
-- Name: math_trainer_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_answers_id_seq'::regclass);


--
-- Name: math_trainer_answers_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers_sessions ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_answers_sessions_id_seq'::regclass);


--
-- Name: math_trainer_card_session_problems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_session_problems ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_card_session_problems_id_seq'::regclass);


--
-- Name: math_trainer_card_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_sessions ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_card_sessions_id_seq'::regclass);


--
-- Name: math_trainer_fight_opponents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fight_opponents ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_fight_opponents_id_seq'::regclass);


--
-- Name: math_trainer_fights id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fights ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_fights_id_seq'::regclass);


--
-- Name: math_trainer_problems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_problems ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_problems_id_seq'::regclass);


--
-- Name: math_trainer_time_sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_time_sessions ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_time_sessions_id_seq'::regclass);


--
-- Name: math_trainer_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_users ALTER COLUMN id SET DEFAULT nextval('public.math_trainer_users_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: participations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participations ALTER COLUMN id SET DEFAULT nextval('public.participations_id_seq'::regclass);


--
-- Name: passeport_availability_checks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passeport_availability_checks ALTER COLUMN id SET DEFAULT nextval('public.passeport_availability_checks_id_seq'::regclass);


--
-- Name: scrapped_rankings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scrapped_rankings ALTER COLUMN id SET DEFAULT nextval('public.scrapped_rankings_id_seq'::regclass);


--
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- Name: section_user_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_user_invitations ALTER COLUMN id SET DEFAULT nextval('public.section_user_invitations_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: selections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.selections ALTER COLUMN id SET DEFAULT nextval('public.selections_id_seq'::regclass);


--
-- Name: sms_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications ALTER COLUMN id SET DEFAULT nextval('public.sms_notifications_id_seq'::regclass);


--
-- Name: starburst_announcement_views id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.starburst_announcement_views ALTER COLUMN id SET DEFAULT nextval('public.starburst_announcement_views_id_seq'::regclass);


--
-- Name: starburst_announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.starburst_announcements ALTER COLUMN id SET DEFAULT nextval('public.starburst_announcements_id_seq'::regclass);


--
-- Name: team_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_sections ALTER COLUMN id SET DEFAULT nextval('public.team_sections_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: training_invitations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_invitations ALTER COLUMN id SET DEFAULT nextval('public.training_invitations_id_seq'::regclass);


--
-- Name: training_presences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_presences ALTER COLUMN id SET DEFAULT nextval('public.training_presences_id_seq'::regclass);


--
-- Name: trainings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings ALTER COLUMN id SET DEFAULT nextval('public.trainings_id_seq'::regclass);


--
-- Name: user_championship_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_championship_stats ALTER COLUMN id SET DEFAULT nextval('public.user_championship_stats_id_seq'::regclass);


--
-- Name: user_channel_messages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_channel_messages ALTER COLUMN id SET DEFAULT nextval('public.user_channel_messages_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: webpush_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webpush_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.webpush_subscriptions_id_seq'::regclass);


--
-- Name: absences absences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences
    ADD CONSTRAINT absences_pkey PRIMARY KEY (id);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: admin_users admin_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users
    ADD CONSTRAINT admin_users_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blocked_addresses blocked_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocked_addresses
    ADD CONSTRAINT blocked_addresses_pkey PRIMARY KEY (id);


--
-- Name: burns burns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.burns
    ADD CONSTRAINT burns_pkey PRIMARY KEY (id);


--
-- Name: calendars calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT calendars_pkey PRIMARY KEY (id);


--
-- Name: championship_group_championships championship_group_championships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_group_championships
    ADD CONSTRAINT championship_group_championships_pkey PRIMARY KEY (id);


--
-- Name: championship_groups championship_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_groups
    ADD CONSTRAINT championship_groups_pkey PRIMARY KEY (id);


--
-- Name: championships championships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships
    ADD CONSTRAINT championships_pkey PRIMARY KEY (id);


--
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- Name: club_admin_roles club_admin_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.club_admin_roles
    ADD CONSTRAINT club_admin_roles_pkey PRIMARY KEY (id);


--
-- Name: clubs clubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clubs
    ADD CONSTRAINT clubs_pkey PRIMARY KEY (id);


--
-- Name: days days_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.days
    ADD CONSTRAINT days_pkey PRIMARY KEY (id);


--
-- Name: duty_tasks duty_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_tasks
    ADD CONSTRAINT duty_tasks_pkey PRIMARY KEY (id);


--
-- Name: enrolled_team_championships enrolled_team_championships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enrolled_team_championships
    ADD CONSTRAINT enrolled_team_championships_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: match_availabilities match_availabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_availabilities
    ADD CONSTRAINT match_availabilities_pkey PRIMARY KEY (id);


--
-- Name: match_invitations match_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_invitations
    ADD CONSTRAINT match_invitations_pkey PRIMARY KEY (id);


--
-- Name: match_selections match_selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_selections
    ADD CONSTRAINT match_selections_pkey PRIMARY KEY (id);


--
-- Name: matches matches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_answer_fights math_trainer_answer_fights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answer_fights
    ADD CONSTRAINT math_trainer_answer_fights_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_answers math_trainer_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers
    ADD CONSTRAINT math_trainer_answers_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_answers_sessions math_trainer_answers_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers_sessions
    ADD CONSTRAINT math_trainer_answers_sessions_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_ar_internal_metadata math_trainer_ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_ar_internal_metadata
    ADD CONSTRAINT math_trainer_ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: math_trainer_card_session_problems math_trainer_card_session_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_session_problems
    ADD CONSTRAINT math_trainer_card_session_problems_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_card_sessions math_trainer_card_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_sessions
    ADD CONSTRAINT math_trainer_card_sessions_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_fight_opponents math_trainer_fight_opponents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fight_opponents
    ADD CONSTRAINT math_trainer_fight_opponents_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_fights math_trainer_fights_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fights
    ADD CONSTRAINT math_trainer_fights_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_problems math_trainer_problems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_problems
    ADD CONSTRAINT math_trainer_problems_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_schema_migrations math_trainer_schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_schema_migrations
    ADD CONSTRAINT math_trainer_schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: math_trainer_time_sessions math_trainer_time_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_time_sessions
    ADD CONSTRAINT math_trainer_time_sessions_pkey PRIMARY KEY (id);


--
-- Name: math_trainer_users math_trainer_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_users
    ADD CONSTRAINT math_trainer_users_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: participations participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participations
    ADD CONSTRAINT participations_pkey PRIMARY KEY (id);


--
-- Name: passeport_availability_checks passeport_availability_checks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passeport_availability_checks
    ADD CONSTRAINT passeport_availability_checks_pkey PRIMARY KEY (id);


--
-- Name: scrapped_rankings scrapped_rankings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scrapped_rankings
    ADD CONSTRAINT scrapped_rankings_pkey PRIMARY KEY (id);


--
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- Name: section_user_invitations section_user_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_user_invitations
    ADD CONSTRAINT section_user_invitations_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: selections selections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.selections
    ADD CONSTRAINT selections_pkey PRIMARY KEY (id);


--
-- Name: sms_notifications sms_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT sms_notifications_pkey PRIMARY KEY (id);


--
-- Name: starburst_announcement_views starburst_announcement_views_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.starburst_announcement_views
    ADD CONSTRAINT starburst_announcement_views_pkey PRIMARY KEY (id);


--
-- Name: starburst_announcements starburst_announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.starburst_announcements
    ADD CONSTRAINT starburst_announcements_pkey PRIMARY KEY (id);


--
-- Name: team_sections team_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.team_sections
    ADD CONSTRAINT team_sections_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: training_presences training_availabilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_presences
    ADD CONSTRAINT training_availabilities_pkey PRIMARY KEY (id);


--
-- Name: training_invitations training_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.training_invitations
    ADD CONSTRAINT training_invitations_pkey PRIMARY KEY (id);


--
-- Name: trainings trainings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trainings
    ADD CONSTRAINT trainings_pkey PRIMARY KEY (id);


--
-- Name: user_championship_stats user_championship_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_championship_stats
    ADD CONSTRAINT user_championship_stats_pkey PRIMARY KEY (id);


--
-- Name: user_channel_messages user_channel_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_channel_messages
    ADD CONSTRAINT user_channel_messages_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webpush_subscriptions webpush_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webpush_subscriptions
    ADD CONSTRAINT webpush_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: index_absences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_absences_on_user_id ON public.absences USING btree (user_id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_admin_comments_on_author_type_and_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_author_type_and_author_id ON public.active_admin_comments USING btree (author_type, author_id);


--
-- Name: index_active_admin_comments_on_namespace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_namespace ON public.active_admin_comments USING btree (namespace);


--
-- Name: index_active_admin_comments_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_admin_comments_on_resource_type_and_resource_id ON public.active_admin_comments USING btree (resource_type, resource_id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_blocked_addresses_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_blocked_addresses_on_email ON public.blocked_addresses USING btree (email);


--
-- Name: index_burns_on_championship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_burns_on_championship_id ON public.burns USING btree (championship_id);


--
-- Name: index_burns_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_burns_on_user_id ON public.burns USING btree (user_id);


--
-- Name: index_calendars_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendars_on_season_id ON public.calendars USING btree (season_id);


--
-- Name: index_championship_group_championships_on_championship_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championship_group_championships_on_championship_group_id ON public.championship_group_championships USING btree (championship_group_id);


--
-- Name: index_championship_group_championships_on_championship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championship_group_championships_on_championship_id ON public.championship_group_championships USING btree (championship_id);


--
-- Name: index_championships_on_calendar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championships_on_calendar_id ON public.championships USING btree (calendar_id);


--
-- Name: index_championships_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championships_on_season_id ON public.championships USING btree (season_id);


--
-- Name: index_channels_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_channels_on_section_id ON public.channels USING btree (section_id);


--
-- Name: index_club_admin_roles_on_club_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_admin_roles_on_club_id ON public.club_admin_roles USING btree (club_id);


--
-- Name: index_club_admin_roles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_club_admin_roles_on_user_id ON public.club_admin_roles USING btree (user_id);


--
-- Name: index_days_on_calendar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_days_on_calendar_id ON public.days USING btree (calendar_id);


--
-- Name: index_duty_tasks_on_club_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_duty_tasks_on_club_id ON public.duty_tasks USING btree (club_id);


--
-- Name: index_duty_tasks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_duty_tasks_on_user_id ON public.duty_tasks USING btree (user_id);


--
-- Name: index_enrolled_team_championships_on_championship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrolled_team_championships_on_championship_id ON public.enrolled_team_championships USING btree (championship_id);


--
-- Name: index_enrolled_team_championships_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_enrolled_team_championships_on_team_id ON public.enrolled_team_championships USING btree (team_id);


--
-- Name: index_groups_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_season_id ON public.groups USING btree (season_id);


--
-- Name: index_groups_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_section_id ON public.groups USING btree (section_id);


--
-- Name: index_groups_trainings_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_trainings_on_group_id ON public.groups_trainings USING btree (group_id);


--
-- Name: index_groups_trainings_on_training_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_trainings_on_training_id ON public.groups_trainings USING btree (training_id);


--
-- Name: index_groups_users_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_group_id ON public.groups_users USING btree (group_id);


--
-- Name: index_groups_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_users_on_user_id ON public.groups_users USING btree (user_id);


--
-- Name: index_match_availabilities_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_availabilities_on_match_id ON public.match_availabilities USING btree (match_id);


--
-- Name: index_match_availabilities_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_availabilities_on_user_id ON public.match_availabilities USING btree (user_id);


--
-- Name: index_match_invitations_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_invitations_on_match_id ON public.match_invitations USING btree (match_id);


--
-- Name: index_match_invitations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_invitations_on_user_id ON public.match_invitations USING btree (user_id);


--
-- Name: index_match_selections_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_selections_on_match_id ON public.match_selections USING btree (match_id);


--
-- Name: index_match_selections_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_selections_on_team_id ON public.match_selections USING btree (team_id);


--
-- Name: index_match_selections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_match_selections_on_user_id ON public.match_selections USING btree (user_id);


--
-- Name: index_matches_on_championship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_championship_id ON public.matches USING btree (championship_id);


--
-- Name: index_matches_on_day_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_day_id ON public.matches USING btree (day_id);


--
-- Name: index_matches_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matches_on_location_id ON public.matches USING btree (location_id);


--
-- Name: index_math_trainer_answer_fights_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answer_fights_on_answer_id ON public.math_trainer_answer_fights USING btree (answer_id);


--
-- Name: index_math_trainer_answer_fights_on_fight_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answer_fights_on_fight_id ON public.math_trainer_answer_fights USING btree (fight_id);


--
-- Name: index_math_trainer_answers_on_card_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answers_on_card_session_id ON public.math_trainer_answers USING btree (card_session_id);


--
-- Name: index_math_trainer_answers_on_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answers_on_problem_id ON public.math_trainer_answers USING btree (problem_id);


--
-- Name: index_math_trainer_answers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answers_on_user_id ON public.math_trainer_answers USING btree (user_id);


--
-- Name: index_math_trainer_answers_sessions_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answers_sessions_on_answer_id ON public.math_trainer_answers_sessions USING btree (answer_id);


--
-- Name: index_math_trainer_answers_sessions_on_time_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_answers_sessions_on_time_session_id ON public.math_trainer_answers_sessions USING btree (time_session_id);


--
-- Name: index_math_trainer_card_session_problems_on_card_session_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_card_session_problems_on_card_session_id ON public.math_trainer_card_session_problems USING btree (card_session_id);


--
-- Name: index_math_trainer_card_session_problems_on_problem_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_card_session_problems_on_problem_id ON public.math_trainer_card_session_problems USING btree (problem_id);


--
-- Name: index_math_trainer_card_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_card_sessions_on_user_id ON public.math_trainer_card_sessions USING btree (user_id);


--
-- Name: index_math_trainer_fights_on_fight_opponent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_fights_on_fight_opponent_id ON public.math_trainer_fights USING btree (fight_opponent_id);


--
-- Name: index_math_trainer_fights_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_fights_on_user_id ON public.math_trainer_fights USING btree (user_id);


--
-- Name: index_math_trainer_time_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_math_trainer_time_sessions_on_user_id ON public.math_trainer_time_sessions USING btree (user_id);


--
-- Name: index_math_trainer_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_math_trainer_users_on_confirmation_token ON public.math_trainer_users USING btree (confirmation_token);


--
-- Name: index_math_trainer_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_math_trainer_users_on_email ON public.math_trainer_users USING btree (email);


--
-- Name: index_math_trainer_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_math_trainer_users_on_reset_password_token ON public.math_trainer_users USING btree (reset_password_token);


--
-- Name: index_math_trainer_users_on_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_math_trainer_users_on_uuid ON public.math_trainer_users USING btree (uuid);


--
-- Name: index_messages_on_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_channel_id ON public.messages USING btree (channel_id);


--
-- Name: index_messages_on_parent_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_parent_message_id ON public.messages USING btree (parent_message_id);


--
-- Name: index_messages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_messages_on_user_id ON public.messages USING btree (user_id);


--
-- Name: index_participations_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_season_id ON public.participations USING btree (season_id);


--
-- Name: index_participations_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_section_id ON public.participations USING btree (section_id);


--
-- Name: index_participations_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_participations_on_user_id ON public.participations USING btree (user_id);


--
-- Name: index_section_user_invitations_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_section_user_invitations_on_section_id ON public.section_user_invitations USING btree (section_id);


--
-- Name: index_sections_on_club_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_club_id ON public.sections USING btree (club_id);


--
-- Name: index_selections_on_match_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_selections_on_match_id ON public.selections USING btree (match_id);


--
-- Name: index_selections_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_selections_on_team_id ON public.selections USING btree (team_id);


--
-- Name: index_selections_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_selections_on_user_id ON public.selections USING btree (user_id);


--
-- Name: index_sms_notifications_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sms_notifications_on_section_id ON public.sms_notifications USING btree (section_id);


--
-- Name: index_team_sections_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_sections_on_section_id ON public.team_sections USING btree (section_id);


--
-- Name: index_team_sections_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_team_sections_on_team_id ON public.team_sections USING btree (team_id);


--
-- Name: index_teams_on_club_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teams_on_club_id ON public.teams USING btree (club_id);


--
-- Name: index_training_invitations_on_training_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_invitations_on_training_id ON public.training_invitations USING btree (training_id);


--
-- Name: index_training_presences_on_training_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_presences_on_training_id ON public.training_presences USING btree (training_id);


--
-- Name: index_training_presences_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_training_presences_on_user_id ON public.training_presences USING btree (user_id);


--
-- Name: index_trainings_on_location_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trainings_on_location_id ON public.trainings USING btree (location_id);


--
-- Name: index_user_championship_stats_on_championship_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_championship_stats_on_championship_id ON public.user_championship_stats USING btree (championship_id);


--
-- Name: index_user_championship_stats_on_championship_id_and_player_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_user_championship_stats_on_championship_id_and_player_id ON public.user_championship_stats USING btree (championship_id, player_id);


--
-- Name: index_user_championship_stats_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_championship_stats_on_user_id ON public.user_championship_stats USING btree (user_id);


--
-- Name: index_user_channel_messages_on_channel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_channel_messages_on_channel_id ON public.user_channel_messages USING btree (channel_id);


--
-- Name: index_user_channel_messages_on_message_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_channel_messages_on_message_id ON public.user_channel_messages USING btree (message_id);


--
-- Name: index_user_channel_messages_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_channel_messages_on_user_id ON public.user_channel_messages USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON public.users USING btree (invitation_token);


--
-- Name: index_users_on_invitations_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invitations_count ON public.users USING btree (invitations_count);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_invited_by_id ON public.users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_webpush_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_webpush_subscriptions_on_user_id ON public.webpush_subscriptions USING btree (user_id);


--
-- Name: starburst_announcement_view_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX starburst_announcement_view_index ON public.starburst_announcement_views USING btree (user_id, announcement_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: groups fk_rails_00def4e4db; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT fk_rails_00def4e4db FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: user_channel_messages fk_rails_06ba0d9ef5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_channel_messages
    ADD CONSTRAINT fk_rails_06ba0d9ef5 FOREIGN KEY (message_id) REFERENCES public.messages(id);


--
-- Name: burns fk_rails_0ff98c47ee; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.burns
    ADD CONSTRAINT fk_rails_0ff98c47ee FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: math_trainer_time_sessions fk_rails_101014aabf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_time_sessions
    ADD CONSTRAINT fk_rails_101014aabf FOREIGN KEY (user_id) REFERENCES public.math_trainer_users(id);


--
-- Name: math_trainer_answers_sessions fk_rails_10bc568b98; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers_sessions
    ADD CONSTRAINT fk_rails_10bc568b98 FOREIGN KEY (time_session_id) REFERENCES public.math_trainer_time_sessions(id);


--
-- Name: math_trainer_card_session_problems fk_rails_1a68b9ce67; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_session_problems
    ADD CONSTRAINT fk_rails_1a68b9ce67 FOREIGN KEY (card_session_id) REFERENCES public.math_trainer_card_sessions(id);


--
-- Name: messages fk_rails_273a25a7a6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_rails_273a25a7a6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: championships fk_rails_28cd7f9140; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships
    ADD CONSTRAINT fk_rails_28cd7f9140 FOREIGN KEY (calendar_id) REFERENCES public.calendars(id);


--
-- Name: math_trainer_answers fk_rails_397d14b689; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers
    ADD CONSTRAINT fk_rails_397d14b689 FOREIGN KEY (problem_id) REFERENCES public.math_trainer_problems(id);


--
-- Name: user_championship_stats fk_rails_3c673c75ba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_championship_stats
    ADD CONSTRAINT fk_rails_3c673c75ba FOREIGN KEY (championship_id) REFERENCES public.championships(id);


--
-- Name: math_trainer_fights fk_rails_4fa7a6c133; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fights
    ADD CONSTRAINT fk_rails_4fa7a6c133 FOREIGN KEY (fight_opponent_id) REFERENCES public.math_trainer_fight_opponents(id);


--
-- Name: math_trainer_answers fk_rails_5a2d47b89b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers
    ADD CONSTRAINT fk_rails_5a2d47b89b FOREIGN KEY (user_id) REFERENCES public.math_trainer_users(id);


--
-- Name: messages fk_rails_5baf0f07af; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_rails_5baf0f07af FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: user_channel_messages fk_rails_5bcec6a1b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_channel_messages
    ADD CONSTRAINT fk_rails_5bcec6a1b6 FOREIGN KEY (channel_id) REFERENCES public.channels(id);


--
-- Name: championship_group_championships fk_rails_630a2514ca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_group_championships
    ADD CONSTRAINT fk_rails_630a2514ca FOREIGN KEY (championship_group_id) REFERENCES public.championship_groups(id);


--
-- Name: duty_tasks fk_rails_63d1d5e703; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_tasks
    ADD CONSTRAINT fk_rails_63d1d5e703 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: math_trainer_answer_fights fk_rails_792464e76b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answer_fights
    ADD CONSTRAINT fk_rails_792464e76b FOREIGN KEY (answer_id) REFERENCES public.math_trainer_answers(id);


--
-- Name: math_trainer_answer_fights fk_rails_87f3f8f273; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answer_fights
    ADD CONSTRAINT fk_rails_87f3f8f273 FOREIGN KEY (fight_id) REFERENCES public.math_trainer_fights(id);


--
-- Name: duty_tasks fk_rails_8982d9731c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_tasks
    ADD CONSTRAINT fk_rails_8982d9731c FOREIGN KEY (club_id) REFERENCES public.clubs(id);


--
-- Name: sms_notifications fk_rails_8bf31290ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT fk_rails_8bf31290ff FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: webpush_subscriptions fk_rails_90c23a43b6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.webpush_subscriptions
    ADD CONSTRAINT fk_rails_90c23a43b6 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_channel_messages fk_rails_9207d54fb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_channel_messages
    ADD CONSTRAINT fk_rails_9207d54fb1 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: absences fk_rails_99832e8dde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.absences
    ADD CONSTRAINT fk_rails_99832e8dde FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: days fk_rails_a3ef261ae8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.days
    ADD CONSTRAINT fk_rails_a3ef261ae8 FOREIGN KEY (calendar_id) REFERENCES public.calendars(id);


--
-- Name: burns fk_rails_b06610d01f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.burns
    ADD CONSTRAINT fk_rails_b06610d01f FOREIGN KEY (championship_id) REFERENCES public.championships(id);


--
-- Name: match_invitations fk_rails_b43dc6188f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_invitations
    ADD CONSTRAINT fk_rails_b43dc6188f FOREIGN KEY (match_id) REFERENCES public.matches(id);


--
-- Name: math_trainer_card_session_problems fk_rails_b6486247b0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_session_problems
    ADD CONSTRAINT fk_rails_b6486247b0 FOREIGN KEY (problem_id) REFERENCES public.math_trainer_problems(id);


--
-- Name: math_trainer_fights fk_rails_b854315c26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_fights
    ADD CONSTRAINT fk_rails_b854315c26 FOREIGN KEY (user_id) REFERENCES public.math_trainer_users(id);


--
-- Name: championship_group_championships fk_rails_c03e8d5650; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championship_group_championships
    ADD CONSTRAINT fk_rails_c03e8d5650 FOREIGN KEY (championship_id) REFERENCES public.championships(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: messages fk_rails_c90b5a8a0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT fk_rails_c90b5a8a0c FOREIGN KEY (parent_message_id) REFERENCES public.messages(id);


--
-- Name: math_trainer_answers_sessions fk_rails_ca8dbcd7ac; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers_sessions
    ADD CONSTRAINT fk_rails_ca8dbcd7ac FOREIGN KEY (answer_id) REFERENCES public.math_trainer_answers(id);


--
-- Name: user_championship_stats fk_rails_cd04ba13f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_championship_stats
    ADD CONSTRAINT fk_rails_cd04ba13f5 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: math_trainer_answers fk_rails_d05e8d6f1c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_answers
    ADD CONSTRAINT fk_rails_d05e8d6f1c FOREIGN KEY (card_session_id) REFERENCES public.math_trainer_card_sessions(id);


--
-- Name: calendars fk_rails_d5af2ea0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT fk_rails_d5af2ea0d7 FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- Name: math_trainer_card_sessions fk_rails_f1a020d53a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.math_trainer_card_sessions
    ADD CONSTRAINT fk_rails_f1a020d53a FOREIGN KEY (user_id) REFERENCES public.math_trainer_users(id);


--
-- Name: channels fk_rails_f6471a0a6e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT fk_rails_f6471a0a6e FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240919161108'),
('20240911191722'),
('20240824082227'),
('20240511190103'),
('20240508190226'),
('20240508190225'),
('20240508190224'),
('20230812101849'),
('20230811135453'),
('20230811120426'),
('20230619061517'),
('20230510192951'),
('20230505130520'),
('20230501224339'),
('20230501224338'),
('20230430231249'),
('20230430230119'),
('20221203131102'),
('20221203130714'),
('20221122023407'),
('20221117125158'),
('20221116214058'),
('20221116170801'),
('20221113133011'),
('20221113132742'),
('20221112112719'),
('20221105151924'),
('20221102220838'),
('20221022103955'),
('20221022102857'),
('20221022101600'),
('20200111155856'),
('20200111153438'),
('20191109141804'),
('20191028203722'),
('20190815120810'),
('20190810083558'),
('20181111222300'),
('20171204231461'),
('20171204231460'),
('20171204231459'),
('20171204011052'),
('20171203223432'),
('20170901203938'),
('20170831214713'),
('20170831210855'),
('20170827132240'),
('20170827131723'),
('20170827130444'),
('20151001220222'),
('20151001205837'),
('20150921195823'),
('20150914210202'),
('20150912195224'),
('20141004110951'),
('20140916002059'),
('20140916001826'),
('20140914200502'),
('20140827075827'),
('20140827001808'),
('20140826213041'),
('20140826212650'),
('20140817220826'),
('20140729202306'),
('20140729201646'),
('20140726224443'),
('20140726215100'),
('20140721221124'),
('20140721220032'),
('20140720162906'),
('20140718224416'),
('20140718003332'),
('20140717141139'),
('20140717140018'),
('20140716195442'),
('20140715224555'),
('20140715220358'),
('20140715220157'),
('20140715205819'),
('20140715205030'),
('20140711223032'),
('20140711220546'),
('20140711215545'),
('20140711215459'),
('20140711204344'),
('20140711204336'),
('20140711200237'),
('20140711200234');

