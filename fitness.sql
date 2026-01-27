
CREATE TYPE TIER AS ENUM (
    'BASIC',
    'PREMIUM',
    'VIP'
);

CREATE TYPE STATUS AS ENUM (
    'ENROLLED',
    'ATTENDED',
    'NO_SHOW',
    'CANCELLED'
);

CREATE TYPE WEEK_DAY AS ENUM (
    'SUN',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT'
);

CREATE TYPE LEVEL AS ENUM (
    'BEGINNER',
    'INTERMEDIATE',
    'ADVANCED'
);

CREATE TYPE INSTRUCTOR AS ENUM (
  'KAY',
  'JAY',
  'FOO',
  'BAR',
  'LAX'
);

CREATE TABLE IF NOT EXISTS member(
    id BIGSERIAL PRIMARY KEY,
    member_number TEXT GENERATED ALWAYS AS (
        'MEM-' || LPAD(id::TEXT, 5, '0')
    ) STORED,
    fname VARCHAR(100) NOT NULL,
    lname VARCHAR(100) NOT NULL,
    email TEXT NOT NULL,
    phone_number TEXT,
    membership_tier TIER NOT NULL,
    join_date TIMESTAMP NOT NULL,
    em_contact_name TEXT NOT NULL,
    em_contact_phone TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS fitness_class (
    id BIGSERIAL PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    description TEXT,
    instructor_name INSTRUCTOR NOT NULL,
    week_day WEEK_DAY NOT NULL,
    start_time TIME NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes BETWEEN 30 AND 120),
    max_capacity INTEGER NOT NULL CHECK (max_capacity >= 0) DEFAULT 0,
    difficulty_level LEVEL NOT NULL DEFAULT 'BEGINNER',
    required_membership_tier TIER NOT NULL DEFAULT 'BASIC'
);


CREATE TABLE IF NOT EXISTS enrollment (
    member_id BIGINT REFERENCES member(id) ON DELETE CASCADE,
    class_id BIGINT REFERENCES fitness_class(id) ON DELETE CASCADE,
    enrollment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status STATUS NOT NULL,
    rating INTEGER,
    feedback TEXT,
    PRIMARY KEY (member_id, class_id),
    CONSTRAINT chk_rating_value CHECK (rating IS NULL OR (rating BETWEEN 1 AND 5)),
    CONSTRAINT chk_attended_feedback CHECK (
        (attendance_status = 'ATTENDED') OR (rating IS NULL AND feedback IS NULL)
    )
);


-- member table
INSERT INTO member (fname, lname, email, phone_number, membership_tier, join_date, em_contact_name, em_contact_phone) VALUES
('John', 'Smith', 'john.smith@example.com', '555-0101', 'PREMIUM', '2023-01-15 10:00:00', 'Jane Smith', '555-0102'),
('Jane', 'Doe', 'jane.doe@example.com', '555-0103', 'VIP', '2022-11-20 11:30:00', 'John Doe', '555-0104'),
('Peter', 'Jones', 'peter.jones@example.com', '555-0105', 'BASIC', '2023-03-10 12:00:00', 'Mary Jones', '555-0106'),
('Mary', 'Williams', 'mary.w@example.com', '555-0107', 'PREMIUM', '2023-05-01 13:45:00', 'David Williams', '555-0108'),
('Chris', 'Brown', 'chris.brown@example.com', '555-0109', 'BASIC', '2024-01-20 09:00:00', 'Patricia Brown', '555-0110'),
('Patricia', 'Davis', 'pat.davis@example.com', '555-0111', 'VIP', '2022-09-10 18:00:00', 'Michael Davis', '555-0112'),
('Michael', 'Miller', 'mike.miller@example.com', '555-0113', 'PREMIUM', '2023-08-08 16:20:00', 'Linda Miller', '555-0114'),
('Linda', 'Wilson', 'linda.w@example.com', '555-0115', 'BASIC', '2024-02-01 14:00:00', 'Robert Wilson', '555-0116'),
('Robert', 'Moore', 'rob.moore@example.com', '555-0117', 'BASIC', '2023-12-25 17:00:00', 'Jennifer Moore', '555-0118'),
('Jennifer', 'Taylor', 'jen.t@example.com', '555-0119', 'VIP', '2022-07-30 20:00:00', 'James Taylor', '555-0120');

-- fitness_class table
INSERT INTO fitness_class (class_name, description, instructor_name, week_day, start_time, duration_minutes, max_capacity, difficulty_level, required_membership_tier) VALUES
('Morning Yoga', 'A relaxing yoga session to start your day.', 'KAY', 'MON', '08:00:00', 60, 20, 'BEGINNER', 'BASIC'),
('HIIT Blast', 'High-Intensity Interval Training for maximum calorie burn.', 'JAY', 'TUE', '18:00:00', 45, 15, 'ADVANCED', 'PREMIUM'),
('Spin Cycle', 'An energetic indoor cycling class.', 'FOO', 'WED', '12:00:00', 50, 25, 'INTERMEDIATE', 'BASIC'),
('Advanced Pilates', 'Challenge your core with advanced Pilates movements.', 'BAR', 'THU', '09:30:00', 75, 12, 'ADVANCED', 'VIP'),
('Zumba Party', 'Dance your way to fitness with this fun Zumba class.', 'LAX', 'FRI', '19:00:00', 60, 30, 'BEGINNER', 'BASIC');

-- enrollment table
-- Assume member IDs are 1-10 and class IDs are 1-5

-- Member 1 (John Smith)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status, rating, feedback) VALUES
(1, 1, '2023-01-16 09:00:00', 'ATTENDED', 5, 'Great class, very relaxing!'),
(1, 2, '2023-01-17 10:00:00', 'ATTENDED', 4, 'Tough but worth it.'),
(1, 3, '2023-01-18 11:00:00', 'NO_SHOW', NULL, NULL);

-- Member 2 (Jane Doe)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status, rating, feedback) VALUES
(2, 2, '2023-02-01 09:00:00', 'ATTENDED', 5, 'Jay is an amazing instructor!'),
(2, 4, '2023-02-02 10:00:00', 'ATTENDED', 5, 'Loved the challenge.'),
(2, 5, '2023-02-03 11:00:00', 'CANCELLED', NULL, NULL);

-- Member 3 (Peter Jones)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status, rating, feedback) VALUES
(3, 1, '2023-03-11 09:00:00', 'ATTENDED', 4, 'Good for beginners.'),
(3, 5, '2023-03-12 10:00:00', 'NO_SHOW', NULL, NULL);

-- Member 4 (Mary Williams)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status, rating, feedback) VALUES
(4, 1, '2023-05-02 09:00:00', 'CANCELLED', NULL, NULL),
(4, 2, '2023-05-03 10:00:00', 'ATTENDED', 3, 'A bit too intense for me.'),
(4, 3, '2023-05-04 11:00:00', 'ATTENDED', 5, 'The instructor had great energy.');

-- Member 5 (Chris Brown)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status) VALUES
(5, 1, '2024-01-21 09:00:00', 'ENROLLED');

-- Member 6 (Patricia Davis)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status, rating, feedback) VALUES
(6, 4, '2022-10-01 09:00:00', 'ATTENDED', 5, 'Exactly what I was looking for in an advanced class.');

-- Member 7 (Michael Miller)
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status) VALUES
(7, 2, '2023-08-09 09:00:00', 'ENROLLED');

-- Additional data
INSERT INTO enrollment (member_id, class_id, enrollment_date, attendance_status) VALUES
(8, 1, '2024-02-02 10:00:00', 'ENROLLED'),
(9, 3, '2024-01-01 11:00:00', 'NO_SHOW'),
(10, 4, '2023-01-01 12:00:00', 'CANCELLED'),
(10, 5, '2023-02-01 13:00:00', 'ATTENDED');
