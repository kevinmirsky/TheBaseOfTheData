
/*
It is important to know where the most alien activity occurs. This
report creates an easy to read table that shows the number of events
per region.
*/
SELECT Regions.RegionName, count(Events.RID) as LifetimeEvents
FROM Regions
	INNER JOIN Events ON Regions.RID = Events.RID
GROUP BY Regions.RegionName
ORDER BY LifetimeEvents DESC;

-- Soldiers Per Class
/*
Retrieves the number of READY soldiers per class. This way XCOM can know where they
are lacking and optimize training of new troops.
*/
SELECT Classes.ClassName, count(activeSoldiers.class) as NumSoldiers
FROM Classes
	LEFT JOIN (
				SELECT Soldiers.Class
				FROM  Soldiers
				WHERE Soldiers.AID IN 
					(
						SELECT Agents.AID
						FROM Agents
						WHERE Agents.statusCode = 1
					)
				) 
                AS ActiveSoldiers
				ON ActiveSoldiers.class = Classes.CID
GROUP BY Classes.ClassName
ORDER BY numSoldiers DESC;

-- Time since last event per region
/*
Gets time since last event per region. Allows XCOM to see what regions have been
hit most recently and can also help see what regions may be "overdue" for hostilities. 
*/
SELECT Regions.RegionName, Min(Age(Events.TimeDetected)) as TimeSinceLast
FROM Regions
	LEFT JOIN Events ON Regions.RID = Events.RID
GROUP BY Regions.RegionName
ORDER BY TimeSinceLast ASC;

-- Soldiers and Agents per base

/*NON FUNCTIONAL*/
SELECT Bases.baseName, count(notSoldiers.AID) as NonCombatants, count(troops.AID) as Combatants
FROM Bases
	LEFT JOIN 
		(
			SELECT Agents.AID, Agents.baseAssignment
			FROM Agents
			WHERE AID NOT IN
				(
					SELECT Soldiers.AID
					FROM Soldiers
				)
		) 
		AS notSoldiers
		ON notSoldiers.baseAssignment = Bases.BID
	LEFT JOIN
		(
			SELECT Soldiers.AID, Agents.baseAssignment
			FROM Soldiers
			INNER JOIN Agents ON Agents.AID = Soldiers.AID
		)
		AS troops
		ON troops.baseAssignment = Bases.BID
GROUP BY Bases.baseName;
