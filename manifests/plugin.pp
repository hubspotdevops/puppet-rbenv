define rbenv::plugin(
  $user,
  $source,
  $plugin_name = $title,
  $group       = $user,
  $home        = '',
  $root        = '',
  $timeout     = 100
) {

  $home_path   = $home ? { '' => "/home/${user}",       default => $home }
  $root_path   = $root ? { '' => "${home_path}/.rbenv", default => $root }
  $plugins     = "${root_path}/plugins"
  $destination = "${plugins}/${plugin_name}"

  if $source !~ /^(git|https):/ {
    fail('Only git plugins are supported')
  }

  if ! defined(File["rbenv::plugins ${user}"]) {
    file { "rbenv::plugins ${user}":
      ensure  => directory,
      path    => $plugins,
      owner   => $user,
      group   => $group,
      require => Exec["rbenv::checkout ${user}"],
    }
  }

  vcsrepo { "rbenv::plugin::checkout ${user} ${plugin_name}":
    ensure   => latest,
    provider => git,
    source   => $source,
    revision => 'master',
    path     => $destination,
  }

  file { $destination :
    ensure  => present,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => Vcsrepo["rbenv::plugin::checkout ${user} ${plugin_name}"]
  }

}
