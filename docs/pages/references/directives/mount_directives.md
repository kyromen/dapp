---
title: Монтирование директорий
sidebar: reference
permalink: mount_directives.html
folder: directive
---
Поддержка сборщиками

- Shell - нет
- Chef - да
- Ansible - нет

## Ruby синтаксис (Dappfile)

### mount \<to\>

Определяет внешнюю директорию сборки для переданного абсолютного пути \<to\>.


#### mount.from

Определяет место размещения директории.

* при 'tmp_dir', во временной директории приложения.
* при 'build_dir', в директории сборки проекта.

#### mount.from_path

Определяет произвольную директорию.

#### Примеры

##### Собрать с несколькими внешними директориями
```ruby
dimg do
  docker.from 'image:tag'

  mount '/any_path' do
    from 'tmp_dir'
  end

  mount '/cache' do
    from 'build_dir'
  end

  mount '/app' do
    from_path '/home/user/test'
  end
end
```
