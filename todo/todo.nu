# This is a simple todo list tool
# It uses a file (essentially a yaml list) to store quick notes
# The last command output is automatically store on the variable '$env.last_todo'
# Allow listing, adding searching and completing tasks
# Use the 'help todo' or 'todo <command> -h' to learn more

export-env {$env.last_todo = []}
 
def --env export-return [] : any -> any {
  let export_todo = $in
  export-env {$env.last_todo = $export_todo}
  return $export_todo
}

def select-multiple [] : table -> table {
  let the_table = $in
  return ($the_table | (if (($in | length) > 1) {$in | insert tmp {|r| [$r.id ": " $r.summary] | str join }| input list --multi 'Select tasks wih space key, confim wiht enter key, abort with q or esc' -d tmp | try {reject -i tmp} } else {$in}));
}

def select-single [] : table -> table {
  let the_table = $in
  return ($the_table | (if (($in | length) > 1) {$in | insert tmp {|r| [$r.id ": " $r.summary] | str join }| input list 'Select tasks wih space key, confim wiht enter key, abort with q or esc' -d tmp | try {reject -i tmp} } else {$in}));
}

def full-fields [full: bool, hide_done: bool = false] : table -> table {
  let $the_table = $in
  return (if ($hide_done) {
    $the_table | if ($full) { $in | reject done } else {$in | select id summary date updated};
  } else {
    $the_table | update done { if ($in == true) { "✅"} else {"⏳"}} | if ($full) { $in } else {$in | select id done summary date updated};
  }) | update date { into datetime } | update updated { if ($in == null) {''} else { $in | into datetime} };
}

# List TODOs
export def --env list [
  --all (-a) # Return all. By default show not done
  --full (-f) # Return all columns
] : nothing -> table {
  let the_list = open $"($env.TODO_MAIN_FILE)" -r | from yaml;
  if ($the_list == null) {
    return [];
  }
  return ((if $all {
    $the_list | full-fields $full;
  } else {
    $the_list |  where done == false | full-fields $full true;
  }) | export-return )
}

# Search a entries on the TODOs list
# If multiple matches are wound a list input picker is prompted
export def --env fuzzy [
  id?: string # the id or summary or a subset of it (might return multiples)
] : [
    string -> table
    nothing -> table
   ] {

  if ($id == null and $in == null) {
    return;
  }

  let d_id = match ($in | describe) {
    'string' => $in,
    _ => $id
  }

  let the_list = open $"($env.TODO_MAIN_FILE)" -r | from yaml;

  return ($the_list | find $id | select-multiple | full-fields true | export-return);
}

# Get (search) an entry of the TODOs list
export def --env by-tag [
  tag?: string # the tag or subset of it (might return multiples)
] : [
    string -> table
    nothing -> table
   ] {
  if ($tag == null and $in == null) {
    return;
  }

  let d_tag = match ($in | describe) {
    'string' => $tag,
    _ => $tag
  }

  let the_list = open $"($env.TODO_MAIN_FILE)" -r | from yaml;

   return ($the_list | filter {|row| ($row.tags | any { |t| $t =~ $d_tag })} | full-fields true | export-return );
  }

# Add an entry to the TODOs list
export def --env add [
  --done (-d), # mark as done
  --links (-l): list, # add links
  --tags (-t): list, # add tags
  ...summary: string # text to add
] : nothing -> nothing {
  let text = ($summary | str join ' ');
  let new_date = (date now);
  let id = ([$text $new_date] | str join | hash md5 | str substring ..10);
  [{id: $id, done: (if ($done) {true} else {false}), summary: $text , date: $new_date , updated: (if ($done) {date now} else {''}), links: ($links | default []), tags: ($tags | default [])}] | export-return | to yaml | save $"($env.TODO_MAIN_FILE)" -a
}

# Complete a task (marking it as done)
# Uses the id to find the desired task
# If --fuzzy is set the id argument accepts a summary excerpt for fuzzy searching
# If multiple matches are wound a list input picker is prompted
export def --env done [
  id?: string # The id or partial id to complete.
  --fuzzy (-f) # Set fuzzy search
] : [
    string -> table
    nothing -> table
   ] {
  if ($id == null and $in == null) {
    return [];
  }

  let d_id = match ($in | describe) {
    'string' => $in,
    _ => $id
  }

  let the_list = open $"($env.TODO_MAIN_FILE)" -r | from yaml;

  let found = ($the_list | if $fuzzy {$in | find $d_id | where {|r| $r.done == false}} else {$in | where { |r| ($r.id like $id and $r.done == false)}});
  let found_count = ($found | length)

  if ($found_count == 0) {
    return ( [] | export-return )
  }

  let selected_id = (if ($found_count == 1) {
    ($found | get 0.id)
  } else {
    ($found | select-single | get id)
  });

   let update_list = $the_list | update updated { |r| if ($r.id == $selected_id and $r.done == false) { date now } else {$r.updated} } | update done { |r| if ($r.id == $selected_id) { true } else {$r.done} };
   $update_list | to yaml | save $"($env.TODO_MAIN_FILE)" -f
   return ($update_list | where id == $selected_id | full-fields true | export-return );
  
}
