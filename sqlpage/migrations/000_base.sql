CREATE TABLE rucher(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT,
    Lon DECIMAL,
    Lat DECIMAL,
    Alt	INTEGER,
    description TEXT
);
CREATE TABLE colonie(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    numero TEXT UNIQUE,
    rucher_id INTEGER REFERENCES rucher(id),
    rang INTEGER,
    couleur TEXT,
    modele TEXT,
    début DATE,
    reine INTEGER,
    souche TEXT,
    caractere TEXT,
    info TEXT,
    tracing TEXT
);
CREATE TABLE couleur(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    coloris TEXT,
    code TEXT
);
CREATE TABLE modele(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT
);
CREATE TABLE tracing(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    etat TEXT
);
CREATE TABLE intervention(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT
);
CREATE TABLE miel(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categorie TEXT
);
CREATE TABLE production(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    annee INTEGER,
    rucher_id INTEGER REFERENCES rucher(id),
    produit INTEGER,
    total INTEGER
);
CREATE TABLE colvisite(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ruche_id INTEGER REFERENCES colonie(id),
    horodatage DATE,
    details TEXT,
    suivi INTEGER,
    tracing INTEGER,
    rucher_id INTEGER REFERENCES rucher(id)
);
CREATE TABLE ruvisite(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rucher_id INTEGER REFERENCES rucher(id),
    horodatage DATE,
    details TEXT,
    suivi TEXT
);
