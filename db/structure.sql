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


SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: championships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.championships (
    id integer NOT NULL,
    season_id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    calendar_id bigint
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
    calendar_id bigint
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
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    queue character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


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
    key character varying
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
    enrolled_name character varying
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
    updated_at timestamp without time zone
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
    shared_calendar_url character varying
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
-- Name: active_admin_comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments ALTER COLUMN id SET DEFAULT nextval('public.active_admin_comments_id_seq'::regclass);


--
-- Name: admin_users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_users ALTER COLUMN id SET DEFAULT nextval('public.admin_users_id_seq'::regclass);


--
-- Name: calendars id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars ALTER COLUMN id SET DEFAULT nextval('public.calendars_id_seq'::regclass);


--
-- Name: championships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships ALTER COLUMN id SET DEFAULT nextval('public.championships_id_seq'::regclass);


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
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


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
-- Name: match_selections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.match_selections ALTER COLUMN id SET DEFAULT nextval('public.match_selections_id_seq'::regclass);


--
-- Name: matches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.matches ALTER COLUMN id SET DEFAULT nextval('public.matches_id_seq'::regclass);


--
-- Name: participations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participations ALTER COLUMN id SET DEFAULT nextval('public.participations_id_seq'::regclass);


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
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: active_admin_comments active_admin_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_admin_comments
    ADD CONSTRAINT active_admin_comments_pkey PRIMARY KEY (id);


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
-- Name: calendars calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT calendars_pkey PRIMARY KEY (id);


--
-- Name: championships championships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships
    ADD CONSTRAINT championships_pkey PRIMARY KEY (id);


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
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


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
-- Name: participations participations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.participations
    ADD CONSTRAINT participations_pkey PRIMARY KEY (id);


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
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


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
-- Name: index_admin_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_email ON public.admin_users USING btree (email);


--
-- Name: index_admin_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_users_on_reset_password_token ON public.admin_users USING btree (reset_password_token);


--
-- Name: index_calendars_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendars_on_season_id ON public.calendars USING btree (season_id);


--
-- Name: index_championships_on_calendar_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championships_on_calendar_id ON public.championships USING btree (calendar_id);


--
-- Name: index_championships_on_season_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_championships_on_season_id ON public.championships USING btree (season_id);


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
-- Name: championships fk_rails_28cd7f9140; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.championships
    ADD CONSTRAINT fk_rails_28cd7f9140 FOREIGN KEY (calendar_id) REFERENCES public.calendars(id);


--
-- Name: duty_tasks fk_rails_63d1d5e703; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.duty_tasks
    ADD CONSTRAINT fk_rails_63d1d5e703 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: sms_notifications fk_rails_8bf31290ff; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sms_notifications
    ADD CONSTRAINT fk_rails_8bf31290ff FOREIGN KEY (section_id) REFERENCES public.sections(id);


--
-- Name: days fk_rails_a3ef261ae8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.days
    ADD CONSTRAINT fk_rails_a3ef261ae8 FOREIGN KEY (calendar_id) REFERENCES public.calendars(id);


--
-- Name: calendars fk_rails_d5af2ea0d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendars
    ADD CONSTRAINT fk_rails_d5af2ea0d7 FOREIGN KEY (season_id) REFERENCES public.seasons(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20140711200234'),
('20140711200237'),
('20140711204336'),
('20140711204344'),
('20140711215459'),
('20140711215545'),
('20140711220546'),
('20140711223032'),
('20140715205030'),
('20140715205819'),
('20140715220157'),
('20140715220358'),
('20140715224555'),
('20140716195442'),
('20140717140018'),
('20140717141139'),
('20140718003332'),
('20140718224416'),
('20140720162906'),
('20140721220032'),
('20140721221124'),
('20140726215100'),
('20140726224443'),
('20140729201646'),
('20140729202306'),
('20140817220826'),
('20140826212650'),
('20140826213041'),
('20140827001808'),
('20140827075827'),
('20140914200502'),
('20140916001826'),
('20140916002059'),
('20141004110951'),
('20150912195224'),
('20150914210202'),
('20150921195823'),
('20151001205837'),
('20151001220222'),
('20170827130444'),
('20170827131723'),
('20170827132240'),
('20170831210855'),
('20170831214713'),
('20170901203938'),
('20171203223432'),
('20171204011052'),
('20171204231459'),
('20171204231460'),
('20171204231461'),
('20181111222300'),
('20190810083558'),
('20190815120810'),
('20191028203722'),
('20191109141804'),
('20200111153438'),
('20200111155856'),
('20221102220838');


