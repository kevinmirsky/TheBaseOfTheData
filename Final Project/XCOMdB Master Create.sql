/*	
-------------------------------------------- 
	 __   _______ ____  __  __     _ ____  
	 \ \ / / ____/ __ \|  \/  |   | |  _ \ 
	  \ V / |   | |  | | \  / | __| | |_) |
	   > <| |   | |  | | |\/| |/ _` |  _ < 
	  / . \ |___| |__| | |  | | (_| | |_) |
	 /_/ \_\_____\____/|_|  |_|\__,_|____/ 
---------------------------------------------
-- By Kevin Mirsky	                                       
*/                                  

-- Drop Statements for Clean Re-writes --
DROP TABLE IF EXISTS StriketeamDeployments CASCADE;
DROP TABLE IF EXISTS Soldiers CASCADE;
DROP TABLE IF EXISTS Striketeams;
DROP TABLE IF EXISTS Classes;
DROP TABLE IF EXISTS Ranks;
DROP TABLE IF EXISTS Agents;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS ThreatLevels;
DROP TABLE IF EXISTS Bases;
DROP TABLE IF EXISTS Regions;
DROP TABLE IF EXISTS Nations;
DROP TABLE IF EXISTS AgentStatuses;

-- Regions -- 
CREATE TABLE Regions (
	RID				serial UNIQUE NOT NULL,
	regionName		text,
PRIMARY KEY(RID)
);

-- Bases -- 
CREATE TABLE Bases (
	BID				serial UNIQUE NOT NULL,
	baseName		text,
	RID				integer references Regions(RID) NOT NULL,
PRIMARY KEY(BID)
);

-- ThreatLevels --
CREATE TABLE ThreatLevels (
	threatLevel		serial UNIQUE NOT NULL,
	threatName		text,
PRIMARY KEY(threatLevel)
);

-- Events --
CREATE TABLE Events (
	EID				serial  UNIQUE NOT NULL,
	codeName		text,
	RID				integer references Regions(RID),
	threatLevel		integer references threatLevels(threatLevel),
	eventDesc		text,
	isActive		boolean NOT NULL,
	timeDetected	timestamp,
PRIMARY KEY(EID)
);

CREATE TABLE Nations (
	nationCode		text UNIQUE NOT NULL,
	nationName		text NOT NULL,
PRIMARY KEY(nationCode)
);

-- AgentStatuses --
CREATE TABLE AgentStatuses (
	statusCode		serial UNIQUE NOT NULL,
	statusName		text,
PRIMARY KEY(statusCode)
);
-- Agents -- 
CREATE TABLE Agents (
	AID				serial UNIQUE NOT NULL,
	firstName		text,
	lastName		text,
	DOB				date,
	nationOfOrigin	text references Nations(nationCode),
	statusCode		integer references AgentStatuses(statusCode) NOT NULL DEFAULT 1,
	baseAssignment	integer references Bases(BID),
PRIMARY KEY(AID)
);

-- Soldiers info tables
	-- Ranks --
	CREATE TABLE Ranks (
		RID				serial UNIQUE NOT NULL,
		rankName		text,
	PRIMARY KEY(RID)
	);

	-- Classes --
	CREATE TABLE Classes (
		CID				serial UNIQUE NOT NULL,
		className		text,
	PRIMARY KEY(CID)
	);
-- End Soldiers info Tables

-- Striketeams --
CREATE TABLE Striketeams (
	TID				serial UNIQUE NOT NULL,
	teamName		text,
	baseOfOperation	integer references Bases(BID),
PRIMARY KEY(TID)
);

-- Soldiers --
CREATE TABLE Soldiers (
	AID				integer references Agents(AID) UNIQUE NOT NULL,
	codeName		text,
	rank			integer references Ranks(RID) DEFAULT 1,
	class			integer references Classes(CID) DEFAULT 1,
	TID				integer references Striketeams(TID),
PRIMARY KEY(AID)
);

-- StriketeamDeployments --
CREATE TABLE StriketeamDeployments (
	MID					serial UNIQUE NOT NULL,
	TID					integer references Striketeams(TID) NOT NULL,
	EID					integer references Events(EID) NOT NULL,
	timeOfDeployment	timestamp,
	isDeployed			boolean NOT NULL,
PRIMARY KEY(MID)
);
/*
---------------------
 ADD VIEWS
---------------------
*/
CREATE OR REPLACE VIEW SoldierInfo AS
SELECT 
	Soldiers.AID,
	Agents.firstName,
	Agents.lastName,
	Soldiers.CodeName,
	Nations.nationName,
	Ranks.rankName,
	Classes.className,
	Bases.baseName,
	Striketeams.teamName,
	AgentStatuses.statusName,
	Agents.DOB
	FROM Soldiers 
		INNER JOIN Agents ON Agents.AID = Soldiers.AID
		LEFT JOIN Nations ON Nations.nationCode = Agents.nationOfOrigin
		LEFT JOIN Bases ON Bases.BID = Agents.baseAssignment
		LEFT JOIN Ranks ON Ranks.RID = Soldiers.rank
		LEFT JOIN Classes ON Classes.CID = Soldiers.class
		LEFT JOIN AgentStatuses ON AgentStatuses.statusCode = Agents.statusCode
		LEFT JOIN Striketeams ON Striketeams.TID = Soldiers.TID;


/*
It's important that all alien events are responded to. In order to ensure none are forgotten
about, the view UnrespondedEvents displays all active events that have not yet had a striketeam
dispatched. It also displays all information about the event in a friendly to read manner.
*/

-- KNOWN ISSUE: Seconds are unnecessarily precise due to Age() function calculating from Now().
-- This is required because otherwise it calculates from midnight, giving incorrect info.
CREATE OR REPLACE VIEW UnrespondedEvents AS
SELECT
	Events.EID,
	Events.CodeName,
	Regions.RegionName,
	ThreatLevels.threatName,
	Events.EventDesc,
	Age(now(), Events.timeDetected) as timeSinceReported
FROM Events
	LEFT JOIN Regions ON Regions.RID = Events.RID
	LEFT JOIN ThreatLevels ON ThreatLevels.ThreatLevel = Events.ThreatLevel
WHERE 
	EID NOT IN (SELECT EID FROM StriketeamDeployments)
	AND isActive = True;

CREATE OR REPLACE VIEW EventHistory AS
SELECT 
	Events.EID,
	Events.CodeName,
	Regions.RegionName,
	ThreatLevels.threatName,
	Events.EventDesc,
	Events.timeDetected,
	Striketeams.teamName as RespondingTeam,
	Age(StriketeamDeployments.timeOfDeployment, Events.timeDetected) as ResponseTime,
	Events.isActive
FROM Events
	LEFT JOIN Regions ON Regions.RID = Events.RID
	LEFT JOIN ThreatLevels ON ThreatLevels.ThreatLevel = Events.ThreatLevel
	LEFT JOIN StriketeamDeployments ON StriketeamDeployments.EID = Events.EID
	LEFT JOIN Striketeams ON Striketeams.TID = StriketeamDeployments.TID
ORDER BY Events.timeDetected DESC;


/*
---------------------
 INSERTING TEST DATA
---------------------
*/

INSERT INTO Regions (regionName)
VALUES ('North America'), ('South America'), ('Europe'), ('Middle East'),
('Africa'), ('Asia'), ('Oceania');

INSERT INTO Bases (baseName, RID)
VALUES ('Area 51', 1), 			-- 1
	('Firebase Alpaca', 2), 
	('Jackal Base', 5), 
	('Kennedy Base', 1),
	('Alps Strikebase', 3), 	-- 5
	('Asian Coalition Base', 6), 
	('Outback Base', 7), 
	('Pyramid Base', 4);		-- 8

INSERT INTO ThreatLevels (threatName)
VALUES ('Minimal'), ('Minor'), ('Moderate'), ('Substantial'), ('High'), ('Severe'),
('Extreme'), ('Critical');

INSERT INTO Ranks (rankName)
VALUES ('Squaddie'), ('Lance Corporal'), ('Corporal'), ('Sergeant'), ('Staff Sergeant'),
('Master Sergeant'), ('Lieutenant'), ('Captain'), ('Major'), ('Colonel'), ('Field Commander');

INSERT INTO AgentStatuses (statusCode, statusName)
VALUES (0, 'KIA'), (1, 'Active'), (2, 'Wounded'), (3, 'Gravely Wounded'), (4, 'MIA'),
(5, 'Retired'), (6, 'Removed from Duty');

INSERT INTO Classes (className)
VALUES ('Rookie'), ('Assault'), ('Grenadier'), ('Gunner'), ('Ranger'), 
('Sharpshooter'), ('Shinobi'), ('Specialist'), ('Technical'), ('Psi Operative');

INSERT INTO Events (codeName, RID, ThreatLevel, EventDesc, isActive, timeDetected)
VALUES
	('Fallen Star', 5, 3, 'A UFO touched down in the Nigerian interior', TRUE, '2017-04-20 15:10:18'),
	('Little Thieves', 1, 3, 'Reports of abductions in rural Kansas', FALSE, '2017-4-28 02:02:12'),
	('Streaked Sky', 1, 2, 'Possible UFO spotting in Canada', FALSE, '2016-12-15 20:32:08'),
	('Vengeful Demon', 6, 5, 'Alien attack on Chinese city', FALSE, '2017-02-01 10:45:59'),
	('Scornful Father', 3, 1, 'Signs of alien activity in German forest', FALSE, '2017-03-11 04:22:13'),
	('Growling Dirt', 2, 2, 'Reports of alien scouts in Peruvian outskirts', TRUE,'2017-04-20 08:01:02'),
	('Big Ocean', 1, 2, 'Reports of submerged UFO in Southern Atlantic Ocean', TRUE, '2017-4-30 15:13:38');

INSERT INTO Nations (nationCode, nationName)
VALUES
	('US', 'United States of America'), 
	('CA','Canada'), 
	('MX','Mexico'),
	('BR','Brazil'), 
	('CL','Chile'),
	('JP', 'Japan'),
	('KR', 'South Korea'),
	('CN', 'China'),
	('TH', 'Thailand'),
	('AU', 'Australia'),
	('GB', 'United Kingdom'),
	('DE', 'Germany'),
	('FR', 'France'),
	('PL', 'Poland'),
	('ZA', 'South Africa');

INSERT INTO Agents (firstName, lastName, DOB, nationOfOrigin, baseAssignment, statusCode)
VALUES
	('Peter', 'Van Doorn', '1987-11-02', 'US', 5, 1),	-- 1
	('Alan', 'Labouseur', NULL, 'US', 2, 1),
	('Maria', 'Klein', '1975-02-23', 'DE', 5, 1),
	('Wiktor', 'Przybylowicz', '1992-09-01', 'PL', 5, 1),
	('Akio', 'Takahashi', '1993-03-15', 'JP', 6, 0),	-- 5
	('Jung', 'Kim', '1990-01-19', 'KR', 6, 1),
	('Kathy', 'Taylor', '1991-07-07', 'GB', 6, 2),
	('Tien', 'Liengtiraphan', '1996-05-25', 'TH', 2, 1),
	('David', 'Windon', '1991-11-21', 'AU', 3, 1),
	('Juan', 'García', '1989-02-11', 'MX', 3, 1), 		-- 10
	('James', 'Wells', '1985-06-12', 'GB', 3, 1),
	('Hanna', 'Windon', '1993-05-27', 'AU', 7, 1),
	('Maria', 'Perez', '1992-11-05', 'MX', 7, 1),
	('Lucas', 'Qi', '1995-02-12', 'CA', 8, 1),
	('Kate', 'Shepard', '1988-11-29', 'US', 8, 1),		-- 15
	('Hans', 'Weber', '1992-03-11', 'DE', 6, 1);


-- HEY, ONLY COPY FROM BELOW WHILE WIP!
-- STRIKETEAMS
INSERT INTO Striketeams (teamName, BaseOfOperation)
VALUES
	('Final Normal Form', 2), -- 1
	('One Man Army', 5),
	('The Hounds', 3),
	('Wavemakers', 7),
	('Spectres', 8),			-- 5
	('Snakehead', 6);

INSERT INTO Soldiers (AID, codeName, rank, class, TID)
VALUES 
	(1, 'The General', 10, 5, 2), -- Van Doorn
	(2, 'The Normalizer', 8, 8, 1), -- Alan
	(4, '', 1, 1, NULL),
	(5, 'Wolf', 3, 2, NULL),
	(7, 'Kat', 2, 5, NULL),
	(8, 'Flourish', 6, 7, 1), -- Tien
	(9, 'Goat', 4, 4, 3),
	(10, '', 3, 8, 3),
	(11, 'H.G.', 5, 6, 3),
	(12, 'Sparkle', 1, 1, 4),
	(13, 'Dragontooth', 7, 9, 4),
	(14, 'Maple', 3, 4, 5),
	(15, 'Renegade', 9, 6, 5),
	(16, 'Viper', 7, 7, 6);

INSERT INTO StriketeamDeployments (EID, TID, timeOfDeployment, isDeployed)
VALUES
	(6, 1, '2017-04-20 08:12:32', TRUE),
	(5, 3, '2017-03-11 08:52:22', FALSE),
	(4, 6, '2017-02-01 11:01:22', FALSE),
	(3, 1, '2016-12-16 01:22:21', FALSE),
	(2, 4, '2017-04-28 02:04:03', FALSE);

-- ST DEPLOYMENTS

/*
---------------------
 ADD SECURITY ROLES
---------------------
*/

-- The admin role is given to trusted XCOM IT technicians whose main
-- responsibility is overseeing the functionality of the database.
-- This means they have full access to the database in order to maintain it.
CREATE ROLE admin;
GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA PUBLIC
TO admin;

-- The Commander is the appointed leader of XCOM and oversees ALL of its functions, from recruitment to event response.
-- The main purpose of this database is to assist him/her in their operation of XCOM.
-- As such, he has almost complete control over the database. However, there is little
-- reason to give the Commander the ability to DELETE records on most tables, as this should not be required
-- in day-to-day operation. This should only be necessary on Striketeams to remove a team.
CREATE ROLE Commander;
GRANT SELECT, INSERT, UPDATE
ON ALL TABLES IN SCHEMA PUBLIC
TO Commander;
GRANT DELETE
ON Striketeams
TO Commander;

-- Officers, or soldiers in combat leadership positions,are allowed to access information
-- about other soldiers for the purposes of putting together striketeams. However, since the
-- decision is ultimately up to the Commander, they can make no modifications.
CREATE ROLE Officer;
GRANT SELECT ON
Agents,
Nations,
AgentStatuses,
Soldiers, 
Striketeams, 
Bases,
Regions,
Ranks,
Classes
TO Officer;

-- 24/7, certain agents are assigned to monitor for alien events. When one is detected,
-- they must be able to log it into the database. This role gives those agents that power.
CREATE ROLE Dispatch;
GRANT SELECT ON
threatLevels,
Regions,
Events
TO Dispatch;
GRANT INSERT, UPDATE
ON Events
TO Dispatch;

-- The Commander has more important things to than input the data of all incoming Agents.
-- So, some agents are in charge of the processing of incoming Agents. Thus, they must have
-- the ability to perform these operations.
CREATE ROLE HR;
GRANT SELECT ON
Nations,
Agents,
AgentStatuses,
Bases,
Regions,
Soldiers,
Classes,
Ranks
TO HR;
GRANT INSERT, UPDATE
ON Agents, Soldiers
TO HR;