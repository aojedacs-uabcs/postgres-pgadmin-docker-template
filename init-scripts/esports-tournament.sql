SET search_path TO public;

CREATE TYPE player_status AS ENUM ('active', 'inactive', 'banned');
CREATE TYPE match_status  AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
CREATE TYPE match_result  AS ENUM ('win', 'loss', 'draw');
CREATE TYPE match_round   AS ENUM ('group_stage', 'quarterfinals', 'semifinals', 'grand_finals');

CREATE TABLE game (
    game_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    genre VARCHAR(50) NOT NULL,
    publisher VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tournament (
    tournament_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    game_id INT NOT NULL,
    prize_pool DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tournament_game 
        FOREIGN KEY (game_id) 
        REFERENCES game(game_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT chk_tournament_dates CHECK (end_date >= start_date)
);

CREATE TABLE player (
    player_id SERIAL PRIMARY KEY,
    gamertag VARCHAR(50) NOT NULL UNIQUE,
    real_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    status player_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE match_game (
    match_id SERIAL PRIMARY KEY,
    tournament_id INT NOT NULL,
    round match_round NOT NULL DEFAULT 'group_stage',
    scheduled_time TIMESTAMPTZ NOT NULL,
    status match_status NOT NULL DEFAULT 'scheduled',
    winner_player_id INT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_match_tournament 
        FOREIGN KEY (tournament_id) 
        REFERENCES tournament(tournament_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_match_winner 
        FOREIGN KEY (winner_player_id) 
        REFERENCES player(player_id) 
        ON DELETE SET NULL
);

CREATE TABLE match_player (
    match_id INT NOT NULL,
    player_id INT NOT NULL,
    score INT NOT NULL DEFAULT 0,
    result match_result NULL,
    PRIMARY KEY (match_id, player_id),
    CONSTRAINT fk_match_player_match 
        FOREIGN KEY (match_id) 
        REFERENCES match_game(match_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_match_player_player 
        FOREIGN KEY (player_id) 
        REFERENCES player(player_id) 
        ON DELETE RESTRICT
);

CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    table_name VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL,
    executed_by VARCHAR(100) NOT NULL DEFAULT CURRENT_USER,
    executed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    details TEXT NULL
);

INSERT INTO game (name, genre, publisher) VALUES
('VALORANT', 'Tactical Shooter', 'Riot Games'),
('League of Legends', 'MOBA', 'Riot Games'),
('Street Fighter 6', 'Fighting', 'Capcom');

INSERT INTO tournament (name, game_id, prize_pool, start_date, end_date) VALUES
('Masters La Paz 2026', 1, 50000.00, '2026-10-10', '2026-10-15'),
('EVO B.C.S. 2026', 3, 15000.00, '2026-11-01', '2026-11-03');

INSERT INTO player (gamertag, real_name, country, status) VALUES
('TenZ', 'Tyson Ngo', 'Canada', 'active'),
('Chronicle', 'Timofey Khromov', 'Russia', 'active'),
('SonicFox', 'Dominique McLean', 'USA', 'active'),
('Tokido', 'Hajime Taniguchi', 'Japan', 'inactive');

INSERT INTO match_game (tournament_id, round, scheduled_time, status, winner_player_id) VALUES
(1, 'grand_finals', '2026-10-15 18:00:00-07', 'completed', 1);

INSERT INTO match_player (match_id, player_id, score, result) VALUES
(1, 1, 3, 'win'),
(1, 2, 1, 'loss');