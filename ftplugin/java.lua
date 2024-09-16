local config = {
    cmd = {'/home/froopy/jdtls/jdt-language-server-1.38.0-202407151826/bin/jdtls'},
    root_dir = vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1]),
}
require('jdtls').start_or_attach(config)
