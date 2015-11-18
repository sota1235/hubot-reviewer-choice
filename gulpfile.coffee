# gulp packages
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'
# npm packages
stylish    = require 'coffeelint-stylish'

gulp.task 'lint', () ->
  gulp.src './libs/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter stylish

  gulp.src './src/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter stylish
