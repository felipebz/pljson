
create or replace
type body json_value as

  constructor function json_value(object_or_array anydata) return self as result as
  begin
    case object_or_array.gettypename
      when sys_context('userenv', 'current_schema')||'.JSON_LIST' then self.typeval := 2;
      when sys_context('userenv', 'current_schema')||'.JSON' then self.typeval := 1;
      else raise_application_error(-20102, 'JSON_Value init error (JSON or JSON\_List allowed)');
    end case;
    self.object_or_array := object_or_array;
    if(self.object_or_array is null) then self.typeval := 6; end if;
    
    return;
  end json_value;

  constructor function json_value(str varchar2) return self as result as
  begin
    self.typeval := 3;
    self.str := str;
    return;
  end json_value;

  constructor function json_value(num number) return self as result as
  begin
    self.typeval := 4;
    self.num := num;
    if(self.num is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value(b boolean) return self as result as
  begin
    self.typeval := 5;
    self.num := 0;
    if(b) then self.num := 1; end if;
    if(b is null) then self.typeval := 6; end if;
    return;
  end json_value;

  constructor function json_value return self as result as
  begin
    self.typeval := 6; /* for JSON null */
    return;
  end json_value;

  static function makenull return json_value as
  begin
    return json_value;
  end makenull;

  member function get_type return varchar2 as
  begin
    case self.typeval
    when 1 then return 'object';
    when 2 then return 'array';
    when 3 then return 'string';
    when 4 then return 'number';
    when 5 then return 'bool';
    when 6 then return 'null';
    end case;
    
    return 'unknown type';
  end get_type;

  member function get_string return varchar2 as
  begin
    if(self.typeval = 3) then 
      return self.str;
    end if;
    return null;
  end get_string;

  member function get_number return number as
  begin
    if(self.typeval = 4) then 
      return self.num;
    end if;
    return null;
  end get_number;

  member function get_bool return boolean as
  begin
    if(self.typeval = 5) then 
      return self.num = 1;
    end if;
    return null;
  end get_bool;

  member function get_null return varchar2 as
  begin
    if(self.typeval = 6) then 
      return 'null';
    end if;
    return null;
  end get_null;

  member function is_object return boolean as begin return self.typeval = 1; end;
  member function is_array return boolean as begin return self.typeval = 2; end;
  member function is_string return boolean as begin return self.typeval = 3; end;
  member function is_number return boolean as begin return self.typeval = 4; end;
  member function is_bool return boolean as begin return self.typeval = 5; end;
  member function is_null return boolean as begin return self.typeval = 6; end;

  member function to_char(spaces boolean default true) return varchar2 as
  begin
    if(spaces is null) then	
      return json_printer.pretty_print_any(self);
    else 
      return json_printer.pretty_print_any(self, spaces);
    end if;
  end;
  
  member procedure to_clob(self in json_value, buf in out nocopy clob, spaces boolean default false) as
  begin
    if(spaces is null) then	
      json_printer.pretty_print_any(self, false, buf);
    else 
      json_printer.pretty_print_any(self, spaces, buf);
    end if;
  end;

  member procedure print(self in json_value, spaces boolean default true) as
  begin
    dbms_output.put_line(self.to_char(spaces));
  end;

end;
/

sho err