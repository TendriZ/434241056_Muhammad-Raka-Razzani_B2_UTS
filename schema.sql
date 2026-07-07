-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.profiles (
  id uuid NOT NULL,
  name text NOT NULL,
  username text NOT NULL UNIQUE,
  role text DEFAULT 'user'::text CHECK (role = ANY (ARRAY['user'::text, 'helpdesk'::text, 'admin'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT profiles_pkey PRIMARY KEY (id),
  CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.tickets (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  user_id uuid NOT NULL,
  title text NOT NULL,
  description text NOT NULL,
  status text DEFAULT 'pending'::text CHECK (status = ANY (ARRAY['pending'::text, 'on_progress'::text, 'resolved'::text])),
  assigned_to uuid,
  image_url text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  category text DEFAULT 'hardware'::text,
  priority text DEFAULT 'medium'::text,
  CONSTRAINT tickets_pkey PRIMARY KEY (id),
  CONSTRAINT tickets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT tickets_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id)
);
CREATE TABLE public.ticket_history (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  ticket_id bigint NOT NULL,
  user_id uuid NOT NULL,
  action text NOT NULL,
  message text,
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  CONSTRAINT ticket_history_pkey PRIMARY KEY (id),
  CONSTRAINT ticket_history_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id),
  CONSTRAINT ticket_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);