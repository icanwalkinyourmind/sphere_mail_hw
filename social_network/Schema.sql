CREATE TABLE relations (
	who	INTEGER,
	withwho	INTEGER
);

CREATE TABLE users (
	id	INTEGER,
	first_name	TEXT,
	last_name	TEXT
);

CREATE INDEX who_idx
ON relations (who);

CREATE INDEX withwho_idx
ON relations (withwho);


