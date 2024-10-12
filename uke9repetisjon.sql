/* 1. Hvilke verdier forekommer i attributtet filmtype i relasjonen filmitem? 
Lag en oversikt over filmtypene og hvor mange filmer innen hver type (7). */

SELECT filmtype, count(*)
FROM filmitem
GROUP BY (filmtype)
ORDER BY count(*) DESC;

/* 2. Skriv ut serietittel, produksjonsår og antall episoder for de 15 eldste 
TV-seriene i filmdatabasen (sortert stigende etter produksjonsår). */

WITH serie_episoder AS (
    SELECT s.seriesid, count(*) AS antall_episoder
    FROM series AS s 
        JOIN episode AS e USING (seriesid)
    GROUP BY s.seriesid
)

SELECT s.maintitle, s.firstprodyear, serie_episoder.antall_episoder
FROM serie_episoder
    JOIN series AS s USING (seriesid)
ORDER BY firstprodyear
LIMIT (15);

/* 3. Mange titler har vært brukt i flere filmer. Skriv ut en oversikt over titler 
som har vært brukt i mer enn 30 filmer. Bak hver tittel skriv antall ganger den er 
brukt. Ordne linjene med hyppigst forekommende tittel først. (12 eller 26). */

WITH titler_antall AS (
    SELECT title, count(*) AS antall
    FROM film 
    GROUP BY title 
)

SELECT title, antall
FROM titler_antall
WHERE antall > 30
ORDER BY antall DESC;

/* 4. Finn de “Pirates of the Caribbean”-filmene som er med i flere enn 3 genre (4) */

WITH potc_filmer AS (
    SELECT filmid, title
    FROM film
    WHERE title LIKE 'Pirates of the Caribbean%'
)

SELECT title, count(*) AS antall_sjangre
FROM potc_filmer JOIN filmgenre USING (filmid)
GROUP BY title
HAVING count(*) > 3;

/* 5. Hvilke verdier (fornavn) forekommer hyppigst i firstname-attributtet i tabellen Person? 
Finn alle fornavn, og sorter fallende etter antall forekomster. Ikke tell med forekomster der 
fornavn-verdien er tom. Begrens gjerne antall rader. (176029 rader, 16108 for flest fornavn). */

SELECT firstname, count(*) AS antall_forekomster
FROM person 
WHERE firstname != ''
GROUP BY firstname
ORDER BY count(*) DESC
LIMIT (15);

/* 6. Finn filmene som er med i flest genrer: Skriv ut filmid, tittel og antall genre, og 
sorter fallende etter antall genre. Du kan begrense resultatet til 25 rader. */

WITH s AS (
    SELECT filmid, count(*) AS antall_sjangre
    FROM filmgenre
    GROUP BY filmid
)

SELECT f.filmid, f.title, s.antall_sjangre 
FROM s JOIN film AS f USING (filmid)
ORDER BY s.antall_sjangre DESC
LIMIT 25;

/* 7. Lag en oversikt over regissører som har regissert mer enn 5 norske filmer. (60) */

WITH norske_filmer AS (
    SELECT filmid
    FROM filmcountry
    WHERE country = 'Norway'
)

SELECT p.lastname || ', ' || p.firstname AS navn
FROM filmparticipation AS fp 
    JOIN film AS f USING (filmid) /* er her fordi */
    JOIN norske_filmer USING (filmid)
    JOIN person AS p USING (personid)
WHERE parttype = 'director'
GROUP BY p.lastname, p.firstname
HAVING count(*) > 5;

/* 8. Skriv ut serieid, serietittel og produksjonsår for TV-serier, sortert fallende 
etter produksjonsår. Begrens resultatet til 50 filmer. Tips: Ikke ta med serier der 
produksjonsåret er null. */

SELECT seriesid, maintitle, firstprodyear 
FROM series
WHERE firstprodyear IS NOT NULL
ORDER BY firstprodyear DESC
LIMIT 50;

/* 9. Hva er gjennomsnittlig score (rank) for filmer med over 100 000 stemmer (votes)? */

SELECT AVG(rank) 
FROM filmrating
WHERE votes > 100000;

/* 10. Hvilke filmer (tittel og score) med over 100 000 stemmer har en høyere score 
enn snittet blant filmer med over 100 000 stemmer (subspørring!) (20). */

WITH snitt AS (
    SELECT AVG(rank) 
    FROM filmrating
    WHERE votes > 100000
)

SELECT f.title, fr.rank AS score
FROM film AS f 
    JOIN filmrating AS fr USING (filmid)
WHERE fr.rank > (SELECT * FROM snitt) AND fr.votes > 100000;

/* 11. Hvilke 100 verdier (fornavn) forekomer hyppigst i firstname-attributtet i tabellen Person? */

SELECT firstname, count(*) AS antall_forekomster
FROM person 
WHERE firstname != ''
GROUP BY firstname
ORDER BY count(*) DESC 
LIMIT 100;

/* 12. Hvilke to fornavn forekommer mer enn 6000 ganger og akkurat like mange ganger? 
(Paul og Peter, vanskelig!) */

WITH over_6000 AS (
    SELECT firstname, count(*) AS antall
    FROM person
    WHERE firstname != ''
    GROUP BY firstname
    HAVING count(*) > 6000
), likt_antall AS (
    SELECT antall, count(*) AS antall_like
    FROM over_6000
    GROUP BY antall
)

SELECT firstname, antall
FROM over_6000
WHERE antall = (SELECT antall FROM likt_antall WHERE antall_like = 2);

/* 13. Hvor mange filmer har Tancred Ibsen regissert? */

WITH person_id AS (
    SELECT personid
    FROM person
    WHERE firstname = 'Tancred' AND lastname = 'Ibsen'
)

SELECT fp.personid, count(*) AS antall_filmer
FROM filmparticipation AS fp
WHERE parttype = 'director' AND personid = (SELECT * FROM person_id)
GROUP BY fp.personid;

/* 14. Lag en oversikt (filmtittel) over norske filmer med mer enn én regissør (135). */

WITH norske_filmer AS (
    SELECT filmid
    FROM filmcountry 
    WHERE country = 'Norway'
)

SELECT f.filmid, f.title, count(*)
FROM film AS f
    JOIN filmparticipation AS fp USING (filmid)
    JOIN norske_filmer USING (filmid)
WHERE parttype = 'director'
GROUP BY f.filmid, f.title
HAVING count(*) > 1;

/* 15. Finn regissører som har regissert alene mer enn 5 norske filmer (utfordring!) (49) */

1. 

WITH norske_filmer AS (
    SELECT filmid
    FROM filmcountry 
    WHERE country = 'Norway'
), bare_en_regissorer AS (
    SELECT filmid, count(*)
    FROM filmparticipation
    WHERE parttype = 'director'
    GROUP BY filmid
    HAVING count(*) = 1
), regissorer AS (
    SELECT personid, filmid
    FROM filmparticipation
    WHERE parttype = 'director'
)

SELECT p.firstname, p.lastname, count(*)
FROM regissorer
    JOIN person AS p USING (personid)
    JOIN film AS f USING (filmid)
WHERE filmid IN (SELECT filmid FROM bare_en_regissorer)
    AND filmid IN (SELECT filmid FROM norske_filmer)
GROUP BY p.firstname, p.lastname
HAVING count(*) > 5
ORDER BY count(*) DESC;

/* 16. Finn tittel, produksjonsår og filmtype for alle kinofilmer som ble produsert i året 1893 (4) */

WITH kinofilmer AS (
    SELECT filmid, filmtype
    FROM filmitem 
    WHERE filmtype = 'C'
)

SELECT f.title, f.prodyear, kinofilmer.filmtype
FROM kinofilmer 
    JOIN film AS f USING (filmid)
WHERE f.prodyear = 1893;

/* 17. Finn navn på alle skuespillere (cast) i filmen Baile Perfumado (14). */

WITH bp_filmid AS (
    SELECT filmid 
    FROM film
    WHERE title = 'Baile Perfumado'
), bp_skuespillere AS (
    SELECT personid
    FROM filmparticipation 
    WHERE filmid = (SELECT * FROM bp_filmid)
        AND parttype = 'cast'
)

SELECT p.firstname, p.lastname
FROM bp_skuespillere
    JOIN person AS p USING (personid);

/* 18. Finn tittel og produksjonsår for alle filmene som Ingmar Bergman har vært regissør (director) for. 
Sorter tuplene kronologisk etter produksjonsår (62). */

WITH ib_personid AS (
    SELECT personid 
    FROM person 
    WHERE firstname = 'Ingmar' 
        AND lastname = 'Bergman'
), ib_deltagelser AS (
    SELECT filmid
    FROM filmparticipation
    WHERE personid = (SELECT * FROM ib_personid)
        AND parttype = 'director'
)

SELECT f.title, f.prodyear 
FROM film AS f
WHERE filmid IN (SELECT * FROM ib_deltagelser)
ORDER BY f.prodyear;

/* 19. Finn produksjonsår for første og siste film Ingmar Bergman regisserte */

WITH ib_personid AS (
    SELECT personid 
    FROM person 
    WHERE firstname = 'Ingmar' 
        AND lastname = 'Bergman'
), ib_deltagelser AS (
    SELECT filmid
    FROM filmparticipation
    WHERE personid = (SELECT * FROM ib_personid)
        AND parttype = 'director'
)

SELECT min(f.prodyear) AS forste, max(f.prodyear) AS siste
FROM film AS F
WHERE filmid IN (SELECT * FROM ib_deltagelser);

/* 20. Finn tittel og produksjonsår for de filmene hvor mer enn 
300 personer har deltatt, uansett hvilken funksjon de har hatt (11). */

WITH over_3000 AS (
    SELECT filmid
    FROM filmparticipation
    GROUP BY filmid
    HAVING count(DISTINCT personid) > 300
)

SELECT f.title AS tittel, f.prodyear AS produksjonsår
FROM film AS f
WHERE filmid IN (SELECT * FROM over_3000);

/* 21. Finn oversikt over regissører som har regissert kinofilmer over et stort tidsspenn. 
I tillegg til navn, ta med antall kinofilmer og første og siste år (prodyear) personen 
hadde regi. Skriv ut alle som har et tidsintervall på mer enn 49 år mellom første og 
siste film og sorter dem etter lengden på dette tidsintervallet, de lengste først (188). */

WITH kinofilmer AS (
    SELECT filmid 
    FROM filmitem 
    WHERE filmtype = 'C'
)

SELECT p.firstname, p.lastname, count(filmid) AS antall, min(f.prodyear), max(f.prodyear)
FROM filmparticipation AS fp
    JOIN person AS p USING (personid)
    JOIN film AS f USING (filmid)
WHERE fp.filmid IN (SELECT * FROM kinofilmer)
    AND fp.parttype = 'director'
GROUP BY p.firstname, p.lastname, p.personid
HAVING (max(f.prodyear) - min(f.prodyear)) > 49
ORDER BY (max(f.prodyear) - min(f.prodyear)) DESC;

/* 22. Finn filmid, tittel og antall medregissører (parttype ’director’) 
(0 der han har regissert alene) for filmer som Ingmar Bergman har regissert (62). */

WITH ib_personid AS (
    SELECT personid 
    FROM person 
    WHERE firstname = 'Ingmar' 
        AND lastname = 'Bergman'
), ib_deltagelser AS (
    SELECT filmid
    FROM filmparticipation
    WHERE parttype = 'director'
        AND personid = (SELECT * FROM ib_personid)
), antall_regissorer AS (
    SELECT filmid, count(*) AS antall
    FROM filmparticipation 
    WHERE filmid IN (SELECT * FROM ib_deltagelser)
        AND parttype = 'director'
    GROUP BY filmid
)

SELECT f.filmid, f.title, antall_regissorer.antall
FROM film AS f
    JOIN antall_regissorer USING (filmid)
WHERE f.filmid IN (SELECT * FROM ib_deltagelser);

/* 23. Finn filmid, antall involverte personer, produksjonsår og rating for 
alle filmer som Ingmar Bergman har regissert. Ordne kronologisk etter produksjonsår (56). */

WITH ib_personid AS (
    SELECT personid 
    FROM person 
    WHERE firstname = 'Ingmar' 
        AND lastname = 'Bergman'
), ib_deltagelser AS (
    SELECT filmid
    FROM filmparticipation
    WHERE parttype = 'director'
        AND personid = (SELECT * FROM ib_personid)
)

SELECT f.filmid, count(DISTINCT personid) AS antall_involverte, f.prodyear, fr.rank
FROM film AS f 
    JOIN filmparticipation AS fp USING (filmid)
    JOIN filmrating AS fr USING (filmid)
WHERE f.filmid IN (SELECT * FROM ib_deltagelser)
GROUP BY f.filmid, f.prodyear, fr.rank
ORDER BY prodyear;

/* 24. Finn produksjonsår og tittel for alle filmer som både Angelina Jolie 
og Antonio Banderas har deltatt i sammen (3). */

WITH aj_personid AS (
    SELECT personid
    FROM person 
    WHERE firstname = 'Angelina'
        AND lastname = 'Jolie'
), ab_personid AS (
    SELECT personid
    FROM person
    WHERE firstname = 'Antonio'
        AND lastname = 'Banderas'
), aj_filmer AS (
    SELECT filmid
    FROM filmparticipation
    WHERE personid IN (SELECT * FROM aj_personid)
), ab_filmer AS (
    SELECT filmid
    FROM filmparticipation
    WHERE personid IN (SELECT * FROM ab_personid)
)

SELECT f.title, f.prodyear 
FROM film AS f
WHERE f.filmid IN (SELECT * FROM aj_filmer)
    AND f.filmid IN (SELECT * FROM ab_filmer);
    
/* 25. Finn tittel, navn og roller for personer som har hatt mer enn én rolle i 
samme film blant kinofilmer som ble produsert i 2003. (Med forskjellige roller mener 
vi cast, director, producer osv. Vi skal altså ikke ha med de som har to ulike cast-roller) */

WITH kinofilmer_2003 AS (
    SELECT f.filmid
    FROM film AS f
        JOIN filmitem AS fi USING (filmid)
    WHERE fi.filmtype = 'C'
        AND f.prodyear = 2003
), antall_roller AS (
    SELECT fp.filmid, fp.personid, count(DISTINCT parttype) AS roller
    FROM filmparticipation AS fp
    WHERE fp.filmid IN (SELECT * FROM kinofilmer_2003)
    GROUP BY fp.filmid, fp.personid
)

SELECT f.title, p.firstname, p.lastname, antall_roller.roller
FROM film AS f
    JOIN antall_roller USING (filmid)
    JOIN person AS p USING (personid)
WHERE antall_roller.roller > 1
ORDER BY antall_roller.roller DESC;

/* 26. Finn navn og antall filmer for personer som har deltatt i mer 
enn 15 filmer i 2008, 2009 eller 2010, men som ikke har deltatt i noen filmer i 2005 (2).*/

WITH antall_deltagelser AS (
    SELECT fp.personid, count(DISTINCT filmid) AS antall
    FROM filmparticipation AS fp
        JOIN film AS f USING (filmid)
    WHERE f.prodyear = 2008 
        OR f.prodyear = 2009 
        OR f.prodyear = 2010
    GROUP BY fp.personid
    HAVING count(DISTINCT filmid) > 15
), deltagere_2005 AS (
    SELECT DISTINCT fp.personid
    FROM filmparticipation AS fp
        JOIN film AS f USING (filmid)
    WHERE f.prodyear = 2005
)

SELECT p.firstname, p.lastname, antall_deltagelser.antall
FROM person AS p
    JOIN antall_deltagelser USING (personid)
WHERE p.personid NOT IN (SELECT * FROM deltagere_2005);

/* 27. Finn navn på regissør og filmtittel for filmer hvor mer enn 200 personer har deltatt, 
uansett hvilken funksjon de har hatt. Ta ikke med filmer som har hatt flere (mer enn én) 
regissører (33). */

WITH over_200 AS (
    SELECT filmid, count(DISTINCT personid) AS deltagere
    FROM filmparticipation
    GROUP BY filmid
    HAVING count(DISTINCT personid) > 200
), en_regissor AS (
    SELECT filmid
    FROM filmparticipation
    WHERE parttype = 'director'
    GROUP BY filmid
    HAVING count(DISTINCT personid) = 1
)

SELECT p.firstname, p.lastname, f.title
FROM film AS f
    JOIN over_200 USING (filmid)
    JOIN en_regissor USING (filmid)
    JOIN filmparticipation AS fp USING(filmid)
    JOIN person AS p USING (personid)
WHERE fp.parttype = 'director';

/* 28. Finn navn i leksikografisk orden på regissører som har regissert alene kinofilmer 
med mer enn 150 deltakere og som har en regissørkarriere (jf. spørsmål 19) på mer enn 49 år (7). */

WITH kinofilmer AS (
    SELECT filmid 
    FROM filmitem
    WHERE filmtype = 'C'
), over_150 AS (
    SELECT filmid
    FROM filmparticipation
    GROUP BY filmid
    HAVING count(DISTINCT personid) > 150
), en_regissor AS (
    SELECT filmid
    FROM filmparticipation
    WHERE parttype = 'director'
    GROUP BY filmid
    HAVING count(DISTINCT personid) = 1
), lang_karriere AS (
    SELECT fp.personid
    FROM filmparticipation AS fp
        JOIN film AS f USING (filmid)
    WHERE fp.parttype = 'director'
    GROUP BY fp.personid
    HAVING (max(f.prodyear) - min(f.prodyear)) > 49
)

SELECT DISTINCT p.firstname, p.lastname
FROM kinofilmer 
    JOIN over_150 USING (filmid)
    JOIN en_regissor USING (filmid)
    JOIN filmparticipation AS fp USING (filmid)
    JOIN person AS p USING (personid)
    JOIN lang_karriere USING (personid)
WHERE parttype = 'director';

