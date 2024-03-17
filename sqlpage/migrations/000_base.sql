CREATE TABLE rucher(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT,
    Lon DECIMAL,
    Lat DECIMAL,
    Alt	INTEGER,
    description TEXT
);
CREATE TABLE colonie(
    numero TEXT PRIMARY KEY,
    rucher_id INTEGER REFERENCES rucher(id),
    rang INTEGER,
    couleur TEXT,
    modele TEXT,
    début DATE,
    reine INTEGER,
    souche TEXT,
    caractere TEXT,
    info TEXT,
    tracing TEXT,
    disparition BOOL
);
CREATE TABLE couleur(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    coloris TEXT NOT NULL,
    code TEXT
);
CREATE TABLE modele(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT NOT NULL
);
CREATE TABLE intervention(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action TEXT NOT NULL
);
CREATE TABLE miel(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    categorie TEXT NOT NULL
);
CREATE TABLE production(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    annee INTEGER,
    rucher_id INTEGER REFERENCES rucher(id),
    produit INTEGER,
    total INTEGER,
    lot TEXT
);
CREATE TABLE colvisite(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ruche_id INTEGER,
    horodatage DATE,
    details TEXT,
    suivi INTEGER,
    tracing INTEGER,
    rucher_id INTEGER REFERENCES rucher(id),
    registre_E BOOL DEFAULT 0
);
CREATE TABLE ruvisite(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rucher_id INTEGER REFERENCES rucher(id),
    horodatage DATE,
    details TEXT,
    suivi TEXT,
    registre_E BOOL DEFAULT 0
);
CREATE TABLE materiel(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    element TEXT
);
CREATE TABLE inventaire(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ruche_id INTEGER,
    element_id INTEGER
);
CREATE TABLE provenance(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    origine TEXT
);
CREATE TABLE produits(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    lot TEXT NOT NULL,
    produits TEXT NOT NULL,
    categorie TEXT,
    nombre INTEGER NOT NULL,
    reste INTEGER,
    vente BOOL DEFAULT 0,
    prix decimal (10, 2) NOT NULL,
    DDM TEXT
);
CREATE TABLE finances(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    operation TEXT,
    categorie TEXT,
    prix decimal (10, 2) NOT NULL,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    facture_id INTEGER,
    moyen TEXT
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name VARCHAR(255) NOT NULL,
    customer_mode INTEGER,
    date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    customer_total NUMERIC
);

CREATE TABLE order_items (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (id),
    FOREIGN KEY (product_id) REFERENCES produits (id),
    PRIMARY KEY (order_id, product_id)
);
