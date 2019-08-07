CREATE TABLE password (
    username varchar(64) PRIMARY KEY,
    password varchar(64) NOT NULL
);

CREATE TABLE writer (
    writer_id serial PRIMARY KEY,
    username varchar(64) NOT NULL REFERENCES password,
    name varchar(64) NOT NULL
);


CREATE TABLE volunteer (
    volunteer_id serial PRIMARY KEY,
    username varchar(64) NOT NULL REFERENCES password,
    name varchar(64) NOT NULL
);


CREATE TABLE article (
    article_id serial PRIMARY KEY,
    title varchar(255) NOT NULL,
    description text NOT NULL,
    body text NOT NULL,
    num_reviews integer,
    publish_time timestamp NOT NULL,
    end_time timestamp,
    max_users integer,
    writer_id integer REFERENCES writer
);


CREATE TABLE tag (
    tag_id serial PRIMARY KEY,
    tag_name varchar(64) NOT NULL UNIQUE
);

CREATE TABLE article_tag (
    article_id integer REFERENCES article,
    tag_id integer REFERENCES tag,
    PRIMARY KEY (article_id,tag_id)
);

CREATE TABLE volunteer_tag (
    volunteer_id integer REFERENCES volunteer,
    tag_id integer REFERENCES tag,
    ex_rating float(24),
    acc_rating float(24),
    PRIMARY KEY (volunteer_id,tag_id)
);

CREATE TABLE article_volunteer (
    volunteer_id integer REFERENCES volunteer,
    article_id integer REFERENCES article,
    assign_time timestamp NOT NULL,
    rating float(24),
    status integer,
    PRIMARY KEY (volunteer_id,article_id)
);

CREATE TABLE section (
	section_id integer,
	article_id integer REFERENCES article,
	length integer,
	PRIMARY KEY (section_id,article_id)
);

CREATE TABLE comment (
	comment_id integer,
	section_id integer,
	article_id integer,
	text varchar(1024),
	volunteer_id integer NOT NULL REFERENCES volunteer,
	CONSTRAINT FK_comment_section FOREIGN KEY(section_id, article_id) REFERENCES section(section_id, article_id),
	PRIMARY KEY (comment_id,section_id,article_id)
);


CREATE FUNCTION make_article_seq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  execute format('create sequence article_seq_%s', NEW.article_id);
  return NEW;
end
$$;

CREATE TRIGGER make_article_seq AFTER INSERT ON article FOR EACH ROW EXECUTE PROCEDURE make_article_seq();


CREATE FUNCTION fill_in_section_seq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  NEW.section_id := nextval('article_seq_' || NEW.article_id);
  execute format('create sequence article_section_seq_%s%s', NEW.article_id,NEW.section_id);
  RETURN NEW;
end
$$;

CREATE TRIGGER fill_in_section_seq BEFORE INSERT ON section FOR EACH ROW EXECUTE PROCEDURE fill_in_section_seq();


CREATE FUNCTION fill_in_comment_seq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  NEW.comment_id := nextval('article_section_seq_' || NEW.article_id || NEW.section_id);
  RETURN NEW;
end
$$;

CREATE TRIGGER fill_in_comment_seq BEFORE INSERT ON comment FOR EACH ROW EXECUTE PROCEDURE fill_in_comment_seq();



CREATE TABLE comment_rating (
	comment_id integer,
	section_id integer,
	article_id integer,
	CONSTRAINT FK_comment_section FOREIGN KEY(section_id, article_id) REFERENCES section(section_id, article_id),
    volunteer_id integer REFERENCES volunteer,
    rating integer CHECK(rating>=0 AND rating<=10),
    PRIMARY KEY (section_id, article_id,comment_id,volunteer_id)
);


INSERT INTO tag (tag_name) VALUES ('Advocacy');
INSERT INTO tag (tag_name) VALUES ('Citizen');
INSERT INTO tag (tag_name) VALUES ('Comics');
INSERT INTO tag (tag_name) VALUES ('Community');
INSERT INTO tag (tag_name) VALUES ('Data');
INSERT INTO tag (tag_name) VALUES ('Enterprise');
INSERT INTO tag (tag_name) VALUES ('Environmental');
INSERT INTO tag (tag_name) VALUES ('Fashion');
INSERT INTO tag (tag_name) VALUES ('Geology');
INSERT INTO tag (tag_name) VALUES ('Innovation');
INSERT INTO tag (tag_name) VALUES ('Social news');
INSERT INTO tag (tag_name) VALUES ('Solutions');
INSERT INTO tag (tag_name) VALUES ('Trade');
INSERT INTO tag (tag_name) VALUES ('Unorthodox');
INSERT INTO tag (tag_name) VALUES ('Video');
INSERT INTO tag (tag_name) VALUES ('Video game');
INSERT INTO tag (tag_name) VALUES ('Tragedy');
INSERT INTO tag (tag_name) VALUES ('Science fiction');
INSERT INTO tag (tag_name) VALUES ('Fantasy');
INSERT INTO tag (tag_name) VALUES ('Mythology');
INSERT INTO tag (tag_name) VALUES ('Adventure');
INSERT INTO tag (tag_name) VALUES ('Mystery');
INSERT INTO tag (tag_name) VALUES ('Drama');
INSERT INTO tag (tag_name) VALUES ('Romance');
INSERT INTO tag (tag_name) VALUES ('Adventure');
INSERT INTO tag (tag_name) VALUES ('Satire');
INSERT INTO tag (tag_name) VALUES ('Horror');
INSERT INTO tag (tag_name) VALUES ('Tragic comedy');
INSERT INTO tag (tag_name) VALUES ('Young adult fiction');
INSERT INTO tag (tag_name) VALUES ('Dystopia');
INSERT INTO tag (tag_name) VALUES ('Science fiction');
INSERT INTO tag (tag_name) VALUES ('Satire');
INSERT INTO tag (tag_name) VALUES ('Drama');
INSERT INTO tag (tag_name) VALUES ('Romance');
INSERT INTO tag (tag_name) VALUES ('Mystery');
INSERT INTO tag (tag_name) VALUES ('Horror');
INSERT INTO tag (tag_name) VALUES ('Health');
INSERT INTO tag (tag_name) VALUES ('Guide');
INSERT INTO tag (tag_name) VALUES ('Travel');
INSERT INTO tag (tag_name) VALUES ('Kids');
INSERT INTO tag (tag_name) VALUES ('Religion');
INSERT INTO tag (tag_name) VALUES ('Science');
INSERT INTO tag (tag_name) VALUES ('History');
INSERT INTO tag (tag_name) VALUES ('Math');
INSERT INTO tag (tag_name) VALUES ('Anthology');
INSERT INTO tag (tag_name) VALUES ('Poetry');
INSERT INTO tag (tag_name) VALUES ('Encyclopedias');
INSERT INTO tag (tag_name) VALUES ('Dictionaries');
INSERT INTO tag (tag_name) VALUES ('Art');
INSERT INTO tag (tag_name) VALUES ('Cookbooks');
INSERT INTO tag (tag_name) VALUES ('Diaries');
INSERT INTO tag (tag_name) VALUES ('Journals');
INSERT INTO tag (tag_name) VALUES ('Prayer books');
INSERT INTO tag (tag_name) VALUES ('Series');
INSERT INTO tag (tag_name) VALUES ('Trilogy');
INSERT INTO tag (tag_name) VALUES ('Biographies');
INSERT INTO tag (tag_name) VALUES ('Autobiographies');
INSERT INTO tag (tag_name) VALUES ('Technology');
INSERT INTO tag (tag_name) VALUES ('Startups');
INSERT INTO tag (tag_name) VALUES ('Politics');

insert into tag(tag_name) values ('Dentist') ;
insert into tag(tag_name) values ('Pharmacist') ;
insert into tag(tag_name) values ('Computer') ;
insert into tag(tag_name) values ('Physician') ;
insert into tag(tag_name) values ('Database') ;
insert into tag(tag_name) values ('Software') ;
insert into tag(tag_name) values ('Physical') ;
insert into tag(tag_name) values ('Web') ;
insert into tag(tag_name) values ('Veterinarian') ;
insert into tag(tag_name) values ('Computer') ;
insert into tag(tag_name) values ('School') ;
insert into tag(tag_name) values ('Physical') ;
insert into tag(tag_name) values ('Interpreter') ;
insert into tag(tag_name) values ('Mechanical') ;
insert into tag(tag_name) values ('Veterinary') ;
insert into tag(tag_name) values ('Epidemiologist') ;
insert into tag(tag_name) values ('IT') ;
insert into tag(tag_name) values ('Market') ;
insert into tag(tag_name) values ('Diagnostic') ;
insert into tag(tag_name) values ('Computer') ;
insert into tag(tag_name) values ('Respiratory') ;
insert into tag(tag_name) values ('Medical') ;
insert into tag(tag_name) values ('Civil') ;
insert into tag(tag_name) values ('Substance') ;
insert into tag(tag_name) values ('Pathologist') ;
insert into tag(tag_name) values ('Landscaper') ;
insert into tag(tag_name) values ('Radiologic') ;
insert into tag(tag_name) values ('Cost') ;
insert into tag(tag_name) values ('Financial') ;
insert into tag(tag_name) values ('Marriage') ;
insert into tag(tag_name) values ('Medical') ;
insert into tag(tag_name) values ('Lawyer') ;
insert into tag(tag_name) values ('Accountant') ;
insert into tag(tag_name) values ('Compliance') ;
insert into tag(tag_name) values ('High') ;
insert into tag(tag_name) values ('Clinical') ;
insert into tag(tag_name) values ('Maintenance') ;
insert into tag(tag_name) values ('Bookkeeping') ;
insert into tag(tag_name) values ('Financial') ;
insert into tag(tag_name) values ('Recreation') ;
insert into tag(tag_name) values ('Insurance') ;
insert into tag(tag_name) values ('Elementary') ;
insert into tag(tag_name) values ('Dental') ;
insert into tag(tag_name) values ('Management') ;
insert into tag(tag_name) values ('Home') ;
insert into tag(tag_name) values ('Pharmacy') ;
insert into tag(tag_name) values ('Construction') ;
insert into tag(tag_name) values ('Public') ;
insert into tag(tag_name) values ('Middle') ;
insert into tag(tag_name) values ('Massage') ;
insert into tag(tag_name) values ('Paramedic') ;
insert into tag(tag_name) values ('Preschool') ;
insert into tag(tag_name) values ('Hairdresser') ;
insert into tag(tag_name) values ('Marketing') ;
insert into tag(tag_name) values ('Patrol') ;
insert into tag(tag_name) values ('School') ;
insert into tag(tag_name) values ('Executive') ;
insert into tag(tag_name) values ('Financial') ;
insert into tag(tag_name) values ('Personal') ;
insert into tag(tag_name) values ('Clinical') ;
insert into tag(tag_name) values ('Business') ;
insert into tag(tag_name) values ('Loan') ;
insert into tag(tag_name) values ('Meeting') ;
insert into tag(tag_name) values ('Mental') ;
insert into tag(tag_name) values ('Nursing') ;
insert into tag(tag_name) values ('Sales') ;
insert into tag(tag_name) values ('Architect') ;
insert into tag(tag_name) values ('Sales') ;
insert into tag(tag_name) values ('HR') ;
insert into tag(tag_name) values ('Plumber') ;
insert into tag(tag_name) values ('Real') ;
insert into tag(tag_name) values ('Glazier') ;
insert into tag(tag_name) values ('Art') ;
insert into tag(tag_name) values ('Customer') ;
insert into tag(tag_name) values ('Logistician') ;
insert into tag(tag_name) values ('Auto') ;
insert into tag(tag_name) values ('Bus') ;
insert into tag(tag_name) values ('Restaurant') ;
insert into tag(tag_name) values ('Child') ;
insert into tag(tag_name) values ('Administrative') ;
insert into tag(tag_name) values ('Receptionist') ;
insert into tag(tag_name) values ('Paralegal') ;
insert into tag(tag_name) values ('Cement') ;
insert into tag(tag_name) values ('Painter') ;
insert into tag(tag_name) values ('Sports') ;
insert into tag(tag_name) values ('Teacher') ;
insert into tag(tag_name) values ('Brickmason') ;
insert into tag(tag_name) values ('Cashier') ;
insert into tag(tag_name) values ('Janitor') ;
insert into tag(tag_name) values ('Electrician') ;
insert into tag(tag_name) values ('Delivery') ;
insert into tag(tag_name) values ('Maid') ;
insert into tag(tag_name) values ('Carpenter') ;
insert into tag(tag_name) values ('Security') ;
insert into tag(tag_name) values ('Fabricator') ;
insert into tag(tag_name) values ('Telemarketer') ;

INSERT INTO PASSWORD VALUES ('w1','w1');
INSERT INTO PASSWORD VALUES ('w2','w2');
INSERT INTO PASSWORD VALUES ('v1','v1');
INSERT INTO PASSWORD VALUES ('v2','v2');

INSERT INTO volunteer (username,name) VALUES ('v1','voluntter1');
INSERT INTO volunteer (username,name) VALUES ('v2','voluntter2');

INSERT INTO writer (username,name) VALUES ('w1','writer1');
INSERT INTO writer (username,name) VALUES ('w2','writer2');

INSERT INTO article (title,description,body,num_reviews,publish_time,end_time,max_users,writer_id) VALUES ('Flipkart Diwali 2018 sale','Deals on Nokia 5.1 Plus, Realme 2 Pro, Redmi Note 5 Pro, more mobiles under Rs 15,000','Flipkart Diwali 2018 sale is now live with deals and discounts on mobiles, laptops, electronics, fashion products and more. During the sale, which will continue till November 5, those who purchase using SBI Bank credit card users can avail 10 per cent instant discount. The site is also offering discounts on budget phones like Xiaomi Redmi Note 5 Pro, Honor 9N, Asus Zenfone Max M1, etc. Nokia 5.1 Plus is also on offer during the festive sale. Let us take a look at the top budget smartphone discounts under Rs 15,000:Nokia 5.1 Plus is the newest budget device from HMD Global and it comes with a glass body design, taller display. The phone feels premium for its price, thanks to smooth curved edges. It sports a 5.86-inch HD+ display with a notch on top and aspect ratio of 19:9. The phone was launched at a price of Rs 10,999 for the 3GB RAM and 32GB storage model.In our review, we said Nokia 5.1 Plus impresses when it comes to performance and battery. We did not encounter any lag or stutter even with several tabs open in Chrome browser, playing games and switching between apps. The dual rear cameras manage to render vibrant images with decent details in good lighting condition. The phone stands out in the budget segment, courtesy of its classy design and clean software experience. Read our full review of Nokia 5.1 Plus.Realme 2 Pro with dewdrop notch design, dual rear cameras is listed at a starting price Rs 13,990 for 4GB RAM and 64GB storage option. This is among the better mid-range options to buy, courtesy its sharp display, modern design, brilliant imaging sensors and capable processing hardware. The performance is good when it comes to daily usage.Realme 2 Pro is also available in a 6GB RAM and 64GB storage variant, priced at Rs 15,990. The top-model with 8GB RAM and 128GB storage costs Rs 17,990. In addition, people can avail up to Rs 13,000 off on exchange as well as 10 per cent instant discount on SBI credit cards. Read our full review of Realme 2 Pro.Honor 9N was launched at a starting price of Rs 11,999 for base storage model (3GB RAM+32GB ROM), though it will be selling for Rs 9,999 during the sale. The 4GB RAM and 64GB storage model gets Rs 2,000 off and is listed for a price of Rs 11,999. Those planning to Honor 9N will not regret their decision as the company has cut the corners to make the phone beat the competition.',0,now(),NULL,10,1);
INSERT INTO article (title,description,body,num_reviews,publish_time,end_time,max_users,writer_id) VALUES ('Second Article','This is the description of A2','This is the oalkjdfsajlfk jasdklf jlsjfkla slf asj fkls dlkf alksdfj alks flash flka sldkf sakljfd lksj dflkas jdflkajs kldf jsf sdflakj sdklf jlksaj dflkaj sdfkldasldkfj salkdf dslfkjdsklfj alk dflklsa;df  lkjsaf',0,now(),NULL,20,2);
INSERT INTO article (title,description,body,num_reviews,publish_time,end_time,max_users,writer_id) VALUES ('Third Article','This is the description of A3','This is the skdfsalkdfjhsdkfjhskdfh aklsdfhjsad hflhsdfjhalsf sjfkla slf asj fkls dlkf alksdfj alks flash flka sldkf sakljfd lksj dflkas jdflkajs kldf jsf sdflakj sdklf jlksaj dflkaj sdfkldasldkfj salkdf dslfkjdsklfj alk dflklsa;df lkjsaf',0,now(),NULL,40,2);


INSERT INTO article_tag VALUES (1,60);
INSERT INTO article_tag VALUES (1,61);


INSERT INTO volunteer_tag VALUES (1,60,0.1,0.1);
INSERT INTO volunteer_tag VALUES (1,2,0.1,0.2);
INSERT INTO volunteer_tag VALUES (2,61,0.2,0.1);
INSERT INTO volunteer_tag VALUES (2,5,0.2,0.2);

INSERT INTO article_volunteer VALUES (1,1,now(),0.1,4);
INSERT INTO article_volunteer VALUES (2,1,now(),0.1,4);
INSERT INTO article_volunteer VALUES (2,2,now(),0.1,4);

INSERT INTO section (article_id,length) VALUES (1,521);
INSERT INTO section (article_id,length) VALUES (1,351);
INSERT INTO section (article_id,length) VALUES (1,466);
INSERT INTO section (article_id,length) VALUES (1,342);
INSERT INTO section (article_id,length) VALUES (1,314);
INSERT INTO section (article_id,length) VALUES (1,380);

INSERT INTO section (article_id,length) VALUES (2,10);
INSERT INTO section (article_id,length) VALUES (2,10);
INSERT INTO section (article_id,length) VALUES (3,10);
INSERT INTO section (article_id,length) VALUES (3,10);


INSERT INTO comment (section_id,article_id,text,volunteer_id) VALUES (1,1,'The flipkart sale will continue till 16th November, and American Express credit card users can avail 10.5 per cent instant discount',1);
INSERT INTO comment (section_id,article_id,text,volunteer_id) VALUES (1,1,'Flipkart is also offering discounts on phones as follows - Xiaomi Redmi Note 5 Pro - 16%, Honor 9N - 22%, Asus Zenfone Max M1 - 19%',2);



INSERT INTO PASSWORD VALUES ('vw1','vw1');
INSERT INTO volunteer (username,name) VALUES ('vw1','voluntterwriter1');
INSERT INTO writer (username,name) VALUES ('vw1','voluntterwriter1');
INSERT INTO article_volunteer VALUES (3,1,now());
INSERT INTO article_volunteer VALUES (3,2,now());



