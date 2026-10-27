create table audit_log_2(
	audit_id serial primary key,
	tablename varchar(50) not null,
	action_type varchar(10) notnull, 
	changed_by varchar(50) not null default current_user,
	changed_at timestamptz not null default current_timestamp,
	old_data jsonb null,
	new_data jsonb null, 
)

create or replace function process_audit_player()
RETURNS TRIGGER AS $$
begin 
	if(TG_OP = 'DELETE') then
		insert into audit_log_2 (tablename, action_type, old_data)
		values ('player', TG_OP, to_jsonb(OLD));
		return old;

	elseif (TG_OP= 'UPDATE') then
		insert into audit_log_2 (tablename, action_type, old_data, new_data)
		values ('player', TG_OP, to_jsonb(OLD), tojsonb(NEW));
		return new;

	elseif (TG_OP = 'INSERT') then
		insert into audit_log_2 (tablename, action_type, old_data, new_data)
		values ('player', TG_OP, to_jsonb(OLD), tojsonb(NEW));
		return new;

	end if;

	return null;
end;
$$ language plpgsql;


create trigger trg_audit_player
after insert or update or delete on player
for each row
execute function process_audit_player()
