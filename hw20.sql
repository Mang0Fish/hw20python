--hw20 python
--1
--COALESCE is a function that returns the first not null value of an item,
--it has an option to return a custom value if a not null value is not found.

--2
CREATE OR REPLACE FUNCTION update_total_students_by_course()
RETURNS TRIGGER
language plpgsql AS
$$
BEGIN
    -- Update the total number of students in the course for the given course_id
    UPDATE courses
    SET total_num_of_students = (
        SELECT COUNT(DISTINCT student_id)
        FROM grades
        WHERE course_id = NEW.course_id
    )
    WHERE course_id = NEW.course_id;

    RETURN NEW;
END
$$;

CREATE TRIGGER update_total_students_trigger
AFTER INSERT ON grades
FOR EACH ROW
EXECUTE FUNCTION update_total_students_by_course();


CREATE OR REPLACE FUNCTION update_total_students_on_delete()
RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
    -- Update the total number of students in the course for the given course_id
    UPDATE courses
    SET total_num_of_students = (
        SELECT COUNT(DISTINCT student_id)
        FROM grades
        WHERE course_id = OLD.course_id  -- Accessing the course_id from the deleted row
    )
    WHERE course_id = OLD.course_id;

    RETURN OLD;  
END
$$;

CREATE TRIGGER update_total_students_after_delete
AFTER DELETE ON grades
FOR EACH ROW
EXECUTE FUNCTION update_total_students_on_delete();

--3
create view full_grades_view as
select 
	s.name,
	c.course_name,
	g.grade
from 
	students s 
join 
	grades g using (student_id)
join 
	courses c using (course_id);	

select * from full_grades_view;

create view above_80_view as 
select 
	grade
from grades g 
where grade > 80;

select * from above_80_view

create view biggest_course_view as
select
*
from courses c
where c.total_num_of_students = (SELECT max(total_num_of_students) FROM courses c)

select * from biggest_course_view

--4
create or replace function best_student(OUT best_grade int, out best_student text)
language plpgsql AS
    $$
        BEGIN
            select g.grade, s.name 
        	into best_grade, best_student
			from grades g join students s using (student_id) where grade = (select max(grade) from grades g);
		end;
    $$;

select * from best_student();