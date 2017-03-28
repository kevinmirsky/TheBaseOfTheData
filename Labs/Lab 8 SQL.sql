
DROP TABLE IF EXISTS FilmActors;
DROP TABLE IF EXISTS FilmDirectors;
DROP TABLE IF EXISTS Actors;
DROP TABLE IF EXISTS Directors;
DROP TABLE IF EXISTS People;
DROP TABLE IF EXISTS Movies;

-- People -- 
CREATE TABLE People (
	PID				integer NOT NULL,
	firstName		text,
	lastName		text,
	address			text,
	DOB				date,
	spousePID		integer references People(PID),
primary key(PID)
);

-- Actors --
CREATE TABLE Actors (
	PID				integer not null references People(PID),
	hairColor		text,
	eyeColor		text,
	heightInches	integer,
	weight			integer,
	favColor		integer,
	SAGAnniversary	date,
primary key(PID)
);

-- Directors --
CREATE TABLE Directors (
	PID 			integer not null references People(PID),
	filmSchool		text,
	DGAnniversary	date,
	favLens			text,
primary key(PID)
);


-- Movies --
CREATE TABLE Movies (
	MPAANum				integer not null,
	title				text,
	releaseYear			int,
	DomesticBOSalesUSD	numeric(15,2),
	ForeignBOSalesUSD	numeric(15,2),
	DiscSalesUSD		numeric(15,2),
primary key(MPAANum)
);


-- Film Actors -- 
CREATE TABLE FilmActors (
	MPAANum 		integer references Movies(MPAANum),
	PID				integer references Actors(PID),
primary key (MPAANum, PID)
);


-- Film Directors -- 
CREATE TABLE FilmDirectors (
	MPAANum 		integer references Movies(MPAANum),
	PID				integer references Directors(PID),
primary key (MPAANum, PID)
);

-- Q4 Query:
/*
SELECT FirstName, LastName
FROM People
WHERE PID IN (SELECT PID
              FROM FilmDirectors
              WHERE MPAANum IN (SELECT MPAANum
                                FROM FilmActors
                                WHERE PID = 007));
*/