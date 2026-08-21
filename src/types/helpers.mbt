///|
pub fn format_double(val : Double, precision : Int) -> String {
  let mult = match precision {
    0 => 1.0
    1 => 10.0
    2 => 100.0
    3 => 1000.0
    4 => 10000.0
    _ => 100.0
  }
  let rounded_int = (val * mult + 0.5).to_int()
  if precision == 0 {
    rounded_int.to_string()
  } else {
    let int_part = rounded_int / mult.to_int()
    let frac_part = rounded_int % mult.to_int()
    let mut frac_str = frac_part.to_string()
    while frac_str.length() < precision {
      frac_str = "0" + frac_str
    }
    int_part.to_string() + "." + frac_str
  }
}

///|
pub fn json_escape_string(s : String) -> String {
  let buf = StringBuilder::new()
  for ch in s {
    if ch == '"' {
      buf.write_string("\"")
    } else if ch == '\\' {
      buf.write_string("\\\\")
    } else if ch == '\n' {
      buf.write_string("\\n")
    } else if ch == '\r' {
      buf.write_string("\\r")
    } else if ch == '\t' {
      buf.write_string("\\t")
    } else {
      buf.write_char(ch)
    }
  }
  buf.to_string()
}
