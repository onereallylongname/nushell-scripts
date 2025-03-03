# List TODOs
export def --env list [
  --all (-a) # Show all. By default show not done
] : nothing -> table {
  let the_list = open $"($env.TODO_MAIN_FILE)" | from yaml;
  if ($the_list == null) {
    return [];
  }
  return (if $all {
    $the_list | update done { if ($in == true) { "✅"} else {"⏳"}} | select id done summary date updated;
  } else {
    $the_list |  where done == false | select id summary date updated;
  }) | update date { into datetime } | update updated { if ($in == null) {''} else { $in | into datetime} };
}

# Get (search) an entry of the TODOs list
export def id [
  id?: string # the id or subset of it (might return multiples)
] : string -> any {

  if ($id == null and $in == null) {
    return;
  }

  let d_id = match ($in | describe) {
    'string' => $in,
    _ => $id
  }

  let the_list = open $"($env.TODO_MAIN_FILE)" | from yaml;

   return ($the_list | find $id | update done { if ($in == true) { "✅"} else {"⏳"}});

}

# Add an entry to the TODOs list
export def add [
  --done (-d), # mark as done
  --links (-l): list, # add links
  --tags (-t): list, # add tags
  ...summary: string # text to add
] : nothing -> nothing {
  let text = ($summary | str join ' ');
  let new_date = (date now);
  let id = ([$text $new_date] | str join | hash md5 | str substring ..10);
  [{id: $id, done: (if ($done) {true} else {false}), summary: $text , date: $new_date , updated: (if ($done) {date now} else {''}), links: ($links | default []), tags: ($tags | default [])}] | to yaml | save $"($env.TODO_MAIN_FILE)" -a
}

# Add an entry to the TODOs list
export def done [
  id?: string # text to add
] : string -> any {

  if ($id == null and $in == null) {
    return;
  }

  let d_id = match ($in | describe) {
    'string' => $in,
    _ => $id
  }

  let the_list = open $"($env.TODO_MAIN_FILE)" | from yaml;

  let found = $the_list | where { |r| ($r.id like $id and $r.done == false) };
  let found_count = ($found | length)

  if ($found_count == 0) {
    return []
  }

  if ($found_count == 1) {
    let update_list = $the_list | update updated { |r| if ($r.id like $d_id and $r.done == false) { date now } else {$r.updated} } | update done { |r| if ($r.id like $d_id) { true } else {$r.done} };
    $update_list | to yaml | save $"($env.TODO_MAIN_FILE)" -f
    return ($update_list | where id like $d_id | update done { if ($in == true) { "✅"} else {"⏳"}} | select id done summary date updated);
  }
  
  error make { msg: $"Ambiguos call matched: ($found | get id )"}
}
