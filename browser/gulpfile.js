var gulp = require('gulp');
var slim = require('gulp-slim');
var coffee = require('gulp-coffee');
//var plumber = require('gulp-plumber');

gulp.task('slim', function() {
    gulp.src('dev/*.slim')
        .pipe(slim({
            pretty:true
        }))
        .pipe(gulp.dest('public/'));
});

gulp.task('coffee', function() {
    gulp.src('dev/*.coffee')
        .pipe(coffee({bare:true}).on('error', function(e){console.log(e)}))
        .pipe(gulp.dest('public/js/'));
});

gulp.task('watch', function() {
    gulp.watch('dev/*.slim', ['slim']);
    gulp.watch('dev/*.coffee', ['coffee']);
});

gulp.task('default', ['slim', 'coffee', 'watch']);