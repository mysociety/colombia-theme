# colombia-theme: Columbia Pregunta

## To install:

    # on vagrant host:
    mkdir -p alaveteli-themes
    cd alaveteli-themes
    git clone git@github.com:mysociety/colombia-theme.git
    cd ../alaveteli
    vagrant up
    vagrant ssh

    # on vagrant guest:
    script/switch-theme.rb colombia-theme
    bundle exec rake assets:clean
    bundle exec rails s
