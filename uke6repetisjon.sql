/* Oppgave 1 - CREATE TABLE */

CREATE SCHEMA uke6rep;

CREATE TABLE uke6rep.Kunde (
    kundenummer SERIAL PRIMARY KEY,
    kundenavn text NOT NULL,
    kundeadresse text,
    postnr int,
    poststed text
);

CREATE TABLE uke6rep.Ansatt (
    ansattnr SERIAL PRIMARY KEY,
    navn text NOT NULL,
    fodselsdato date,
    ansattdato date
);

CREATE TABLE uke6rep.Prosjekt (
    prosjektnummer SERIAL PRIMARY KEY,
    prosjektleder int REFERENCES uke6rep.Ansatt(ansattnr),
    prosjektnavn text NOT NULL,
    kundenummer int REFERENCES uke6rep.Kunde(kundenummer),
    status text CHECK (status = 'planlagt'
                    OR status = 'aktiv'
                    OR status = 'ferdig')
);

CREATE TABLE uke6rep.AnsattDeltarIProsjekt (
    ansattnr int REFERENCES uke6rep.Ansatt(ansattnr),
    prosjektnr int REFERENCES uke6rep.Prosjekt(prosjektnummer),
    CONSTRAINT pk PRIMARY KEY (ansattnr, prosjektnr)
);

/* Oppgave 2 - Teori */

/* 

a. Hva er primærnøkkelen i relasjonen Ansatt? Hva med relasjonen AnsattDeltarIProsjekt? 

    Ansatt: ansattnr, AnsattDeltarIProsjekt: {ansattnr, prosjektnr}

b. Hva er nøkkelattributtene i relasjonen Ansatt? Hva med relasjonen AnsattDeltarIProsjekt?

    Ansatt: ansattnr, AnsattDeltarIProsjekt: ansattnr, prosjektnr

c. Har relasjonen Ansatt en kandidatnøkkel? I så fall, hva er kandidatnøkkelen?

    {ansattnr}

d. Hva er supernøklene i relasjonen Ansatt?

    Alle kombinasjoner som inneholder ansattnr vil være supernøkler. 

*/

/* Oppgave 3 - INSERT */

INSERT INTO uke6rep.Kunde (kundenavn, kundeadresse, postnr, poststed)
VALUES ('NSB', 'Knut Valstads vei 32', 0690, 'Oslo'),
       ('Norgesgrupppen', 'Kringkollen 3', 0689, 'Oslo'),
       ('SATS', NULL, 0690, 'Oslo');

INSERT INTO uke6rep.Ansatt (navn, fodselsdato, ansattdato)
VALUES ('Aleksander Henriksen', '2002-01-08', '2022-12-04'),
       ('Ole Thomasrud', '1974-11-12', '1999-03-03'),
       ('Berit Bakken', NULL, '1998-08-12');

INSERT INTO uke6rep.Prosjekt (prosjektleder, prosjektnavn, kundenummer, status)
VALUES (1, 'Prosjekt 1', 1, 'aktiv'),
       (2, 'Prosjekt 2', 2, 'planlagt'),
       (1, 'Prosjekt 3', 1, 'ferdig');

INSERT INTO uke6rep.AnsattDeltarIProsjekt (ansattnr, prosjektnr)
VALUES (3, 10),
       (1, 11),
       (2, 12);

/* Oppgave 4 - SELECT */

/* a. En liste over alle kunder. Listen skal inneholde kundenummer, kundenavn og kundeadresse. */

SELECT kundenummer, kundenavn, kundeadresse
FROM uke6rep.Kunde;

/* b. Navn på alle prosjektledere. Dersom en ansatt er prosjektleder for flere prosjekter skal navnet kun forekomme en gang. */

SELECT DISTINCT a.navn
FROM uke6rep.Ansatt AS a 
    JOIN uke6rep.Prosjekt AS p ON (a.ansattid = p.prosjektleder);

/* c. Alle ansattnummerene som er knyttet til prosjektet med prosjektnavn 'Ruter app'. */

UPDATE uke6rep.Prosjekt
SET prosjektnavn = 'Ruter app'
WHERE prosjektnavn = 'Prosjekt 2';

SELECT ap.ansattnr
FROM uke6rep.AnsattDeltarIProsjekt AS ap 
    JOIN uke6rep.Prosjekt AS p ON (ap.prosjektnr = p.prosjektnummer)
WHERE p.prosjektnavn = 'Ruter app';

/* d. En liste over navn på alle ansatte som er knyttet til prosjekter som har kunden med navn 'NSB'. */

SELECT a.navn
FROM uke6rep.Ansatt AS a 
    JOIN uke6rep.AnsattDeltarIProsjekt AS ap USING (ansattnr)
    JOIN uke6rep.Prosjekt AS p ON (ap.prosjektnr = p.prosjektnummer)
    JOIN uke6rep.Kunde AS k ON (p.kundenummer = k.kundenummer)
WHERE k.kundenavn = 'NSB';

