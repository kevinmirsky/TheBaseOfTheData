-- Each function has a test statement ready to go. 
-- Just highlight and run.

-- #1 --
create or replace function PreReqsFor(courseNumber integer) 
returns table (
    prereqnumber int
)
    as $$
Begin
	RETURN QUERY
        SELECT prereqnum
        FROM prerequisites
        WHERE courseNumber = coursenum;
End;
$$ language plpgsql;

begin;
SELECT PreReqsFor(499);


-- #2 --
create or replace function isPreReqFor(courseNumber integer) 
returns table (
    RequiredFor int
)
    as $$
Begin
	RETURN QUERY
        SELECT coursenum
        FROM prerequisites
        WHERE courseNumber = prereqnum;
End;
$$ language plpgsql;

begin;
SELECT isPreReqFor(120);