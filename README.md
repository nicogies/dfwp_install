# wordpress-installer
WordPress (auto) installer with WP-Cli

## Features
- Create the database
- Install latest WordPress
- Generate secure admin credentials
- Empty WordPress contents and plugin
- Create standard page
- Setup homepage with 'Home' page
- Setup permalink with /%postname%/ structure and generate .htaccess file
- Add security rules in .htaccess file
- Add WordPress rules in wp-config file
- Download your favorite theme (public/pro)
- Create a child theme and activate it
- Install and activate listed publics plugins in txt file
- Install and activate licensed plugins placed in the pro_plugins folder
- Install and active ACF Pro with your keygen (remote download)
- Allow to push projet on Gitlab

## Known Issues
- 	Plugins activation is disabled : On some plugins register_activation_hook is not triggered by WP-CLI

## Use :
```sh
bash install.sh
```

### Vagrant configuration

```rb
  # Fix for slow external network connections
    config.vm.provider :virtualbox do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
      vb.customize ['modifyvm', :id, '--natdnsproxy1', 'on']
    end
```
