const withNextIntl = require("next-intl/plugin")();

module.exports = withNextIntl({
  output: "standalone",
  reactStrictMode: false,
  basePath: '/postcovid-dashboard',
  assetPrefix: "https://projects.ugr.es/postcovid-dashboard",
});
