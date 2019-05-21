# See README.md.
class mattermost::config inherits mattermost {
  $override_options = $mattermost::override_options
  $conf = $mattermost::conf
  $dir = regsubst(
    $mattermost::dir,
    '__VERSION__',
    $mattermost::version
  )
  $custom_augeas_dir = '/usr/local/share/augeas'
  $custom_lens_dir = "$custom_augeas_dir/lenses"
  $custom_lens_sec_dir = "$custom_lens_dir/puppet-mattermost"
  $source_conf = "${dir}/config/config.json"
  file { $conf:
    source  => $source_conf,
    owner   => $mattermost::user,
    group   => $mattermost::group,
    mode    => '0644',
    replace => false,
  } ->
  augeas{ $conf:
    changes   => template('mattermost/config.json.erb'),
    lens      => 'Mattermost_json.lns',
    load_path => "$custom_lens_sec_dir",
    incl      => $conf,
  }

  ensure_resources('file', { "$custom_augeas_dir" => {}, "$custom_lens_dir" => {} }, {
    ensure => directory,
  })
  File[$custom_augeas_dir] -> File[$custom_lens_dir]

  file { "$custom_lens_sec_dir":
    ensure  => directory,
    purge   => true,
    recurse => true,
    require => File[$custom_lens_dir],
  }
  file { "$custom_lens_sec_dir/mattermost_json.aug":
    ensure  => file,
    source  => "puppet:///modules/$module_name/mattermost_json.aug",
    require => File[$custom_lens_sec_dir],
    before  => Augeas[$conf],
  }
}
