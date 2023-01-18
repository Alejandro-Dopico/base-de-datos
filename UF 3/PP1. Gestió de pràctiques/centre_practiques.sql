DROP DATABASE IF EXISTS practiques;
CREATE DATABASE practiques;
USE practiques;

CREATE TABLE IF NOT EXISTS tutor_alumne(
    id_ta INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    nom_tutor_centre VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_ta)
); 

CREATE TABLE IF NOT EXISTS tutor_empresa(
    id_te INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    nom_tutor_empresa VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_te)
);

CREATE TABLE IF NOT EXISTS cicle(
    id_cicle INT(2) ZEROFILL NOT NULL AUTO_INCREMENT,
    nom_cicle VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_cicle)
);

CREATE TABLE IF NOT EXISTS empresa(
    id_empresa INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    id_te INT(5) ZEROFILL NOT NULL,
    nom VARCHAR(50) NOT NULL,
    adreça VARCHAR(50) NOT NULL,
    telefon INT(9) NOT NULL,
    email VARCHAR(30) NOT NULL,
    cicles_homologats VARCHAR(50) NOT NULL,
    tipus ENUM('FCT', 'DUAL', 'TOTES') NOT NULL,
    PRIMARY KEY (id_empresa),
    FOREIGN KEY (id_te) REFERENCES tutor_empresa(id_te)
);

CREATE TABLE IF NOT EXISTS alumne(
    id_alumne INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    id_cicle INT(5) ZEROFILL NOT NULL,
    nom VARCHAR(20) NOT NULL,
    cognom VARCHAR(20) NOT NULL,
    data_naixement DATE NOT NULL,
    email VARCHAR(20) NOT NULL,
    telefon INT(9) NOT NULL,
    qualificacio DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (id_alumne),
    FOREIGN KEY (id_cicle) REFERENCES cicle(id_cicle)       
);

CREATE TABLE IF NOT EXISTS practica(
    id_practica INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    id_alumne INT(5) ZEROFILL NOT NULL,
    id_empresa INT(5) ZEROFILL NOT NULL,
    id_ta INT(5) ZEROFILL NOT NULL,  
    data_inici TIMESTAMP NOT NULL,
    data_fi TIMESTAMP NOT NULL,
    num_hores INT NOT NULL,
    tipus ENUM('FCT', 'DUAL'),
    exempcio ENUM('NO' ,'25%', '50%', '100%'),   
    PRIMARY KEY (id_practica),
    FOREIGN KEY (id_alumne) REFERENCES alumne(id_alumne),
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_ta) REFERENCES tutor_alumne(id_ta)    
);


CREATE TABLE IF NOT EXISTS homologacio(
    id_homologacio INT(5) ZEROFILL NOT NULL AUTO_INCREMENT,
    id_empresa INT(5) ZEROFILL NOT NULL,
    id_cicle INT(5) ZEROFILL NOT NULL,
    tipus ENUM('FCT', 'DUAL', 'TOTES') NOT NULL,
    PRIMARY KEY (id_homologacio),
    FOREIGN KEY (id_empresa) REFERENCES empresa(id_empresa),
    FOREIGN KEY (id_cicle) REFERENCES cicle(id_cicle)
);

INSERT INTO tutor_alumne (nom_tutor_centre) VALUES
	("Raquel Alaman"),
	("Albert Alonso"),
	("Joan Montedeoca")
;

INSERT INTO tutor_empresa (nom_tutor_empresa) VALUES
	("Manuel Hernandez"),
	("Alejandro Rodriguez"),
	("Pedro Sanchez")
;

INSERT INTO cicle (nom_cicle) VALUES
	("DAW - Desenvolupament Aplicacions Web"),
	("ASIX - Administració de Xarxes i Sistemes Operatius"),
	("SMIX - Sistemes Microinformàtics i Xarxes")
;

INSERT INTO empresa (id_te, nom, adreça, telefon, email, cicles_homologats, tipus) VALUES
	(1, "CISCO Company", "Santa Maria 47", 937563223, "cisco@gmail.com", "ASIX", "DUAL"),
	(2, "GSP Location", "Marina Sant fosc 27", 956564327, "gsplocation@gmail.com", "DAW", "TOTES"),
	(3, "Cuevas Dessing", "Springfield 22, 3", 987554281, "cuevas@gmail.com", "SMIX", "FCT")	
;

INSERT INTO alumne (id_cicle, nom, cognom, data_naixement, email, telefon, qualificacio) VALUES
	(3, "Alvaro", "Hernandez", '2003-05-03', "ahernadez@gmail.com", 678456352, 6.35),
	(2, "Marko", "Pareja", '2004-04-10', "mpareja@gmail.com", 629874635, 8.5),
	(1, "Alejandro", "Dopico", '1996-02-11', "adopico@gmail.com", 605648688, 7.5),
	(1, "Ayman", "abhal", '2002-06-29', "abhal@gmail.com", 692345677, 5.2)	
;

INSERT INTO practica (id_alumne, id_empresa, id_ta, data_inici, data_fi, num_hores, tipus, exempcio) VALUES
	(3, 2, 1, '2023-05-03 08:00:00', '2023-08-13 14:00:00', 350, "FCT", 'NO'),
	(2, 3, 2, '2023-04-10 16:00:00', '2023-10-22 20:00:00', 350, "DUAL", 'NO'),
	(1, 1, 3, '2023-02-11 07:00:00', '2023-06-20 13:00:00', 220,"FCT", '50%')	
;

INSERT INTO homologacio (id_empresa, id_cicle, tipus) VALUES
	(2, 1, 'TOTES'),
	(3, 2, 'FCT'),
	(1, 3, 'DUAL')	
;


DELIMITER //
CREATE TRIGGER comprovar_data_inici BEFORE INSERT ON practica
FOR EACH ROW
	BEGIN
  	IF (NEW.data_inici < NOW()) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No es poden inserir pràctiques amb data d inici anteriors a la data actual';
  END IF;
END//

CREATE TRIGGER comprovar_data_fi BEFORE UPDATE ON practica
FOR EACH ROW
	BEGIN
  	IF (NEW.data_fi < NEW.data_inici) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No es poden actualitzar pràctiques amb data de finalització anteriors a la data d inici';
  END IF;
END//

/* El ultim trigger al ser una consulta de la mateixa taula, no se com executar-ho. Potser creant una funcio pero he estat provant i no em surt.

CREATE TRIGGER eliminar_registre BEFORE DELETE ON practica
FOR EACH ROW
	BEGIN
  	IF SELECT (id_alumne FROM alumne WHERE id_alumne=OLD.id_alumne) = NEW.id_alumne THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No es poden eliminar pràctiques que siguin l única referència a alumnes o empreses';
  END IF;
END//

*/  

DELIMITER ;


INSERT INTO practica (id_alumne, id_empresa, id_ta, data_inici, data_fi, num_hores, tipus, exempcio) VALUES
	(4, 2, 1, '2023-01-17 08:00:00', '2024-03-13 14:00:00', 350, "FCT", 'NO')	
;

UPDATE practica SET data_fi = '2023-01-11 07:00:00' WHERE id_alumne="1";

/*

	DELETE FROM practica WHERE id_practica="1"; -> EL ultim trigger no he aconseguit que funcioni.


	He posat 1 intent per trigger per verificar si el funcionament del trigger es correcte
	
*/



