const { src, dest, series, parallel, watch } = require('gulp');
const zip = require('gulp-zip');
const { createClient } = require('@existdb/gulp-exist');
const { deleteAsync } = require('del');
const fs = require('fs');

const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
const existConfig = JSON.parse(fs.readFileSync('.existdb.json', 'utf8'));
const serverConfig = existConfig.servers.localhost;
const targetCollection = serverConfig.root;

const exist = createClient({
    basic_auth: {
        user: serverConfig.user,
        pass: serverConfig.password
    },
    host: new URL(serverConfig.server).hostname,
    port: new URL(serverConfig.server).port,
    secure: false
});

function clean() {
    return deleteAsync(['build', 'dist']);
}

function copySource() {
    return src('src/**/*', { encoding: false })
        .pipe(dest('build/'));
}

function copyPackageDescriptors() {
    return src(['expath-pkg.xml', 'repo.xml'], { encoding: false })
        .pipe(dest('build/'));
}

function copyFore() {
    return src([
        'node_modules/@jinntec/fore/dist/fore.js',
        'node_modules/@jinntec/fore/dist/fore.css',
        'node_modules/@jinntec/fore/dist/fore.js.map'
    ], { encoding: false, allowEmpty: true })
        .pipe(dest('build/resources/fore/'));
}

function createXar() {
    const xarName = `${packageJson.name}-${packageJson.version}.xar`;
    return src('build/**/*', { encoding: false })
        .pipe(zip(xarName))
        .pipe(dest('dist/'));
}

function installXar() {
    const xarName = `${packageJson.name}-${packageJson.version}.xar`;
    return src(`dist/${xarName}`, { encoding: false })
        .pipe(exist.install({ packageUri: `http://www.monasterium.net/mom-ca` }));
}

function deploy() {
    return src('build/**/*', { encoding: false })
        .pipe(exist.dest({ target: targetCollection }));
}

function watchSource() {
    watch('src/**/*', series(copySource, deploy));
}

const build = series(clean, parallel(copySource, copyPackageDescriptors, copyFore));
const xar = series(build, createXar);
const install = series(xar, installXar);

exports.clean = clean;
exports.build = build;
exports.xar = xar;
exports.install = install;
exports.deploy = series(build, deploy);
exports.default = series(build, deploy, watchSource);
