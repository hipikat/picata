// TODO: add this all back in from picata...
//
// Use e.g. `webpack --env (debug|prod)[,minify][,clean]`, or
// everything will just default to clean, minified production mode.
//
// "clean" will strip comments and console.log() calls from the source,
//    and collect comments containing copyright or license information
//    into extracted-comments.txt.

// "minify" compresses files, inserts ".min" before filetype suffixes,
//    and create map files. It takes longer than "nominify".
//
// "prod" cleans and minifies all files, while "debug" does not.
//

const path = require('path');
const webpack = require("webpack");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin");
const TerserPlugin = require("terser-webpack-plugin");

const PROJECT_PATH = path.resolve(__dirname),
  ASSET_PATH = process.env.ASSET_PATH || "build/webpack",
  STATIC_PATH = process.env.STATIC_PATH || "/static",
  dev_debug_port = 8681,
  dev_prod_port = 8680;

module.exports = (env) => {
  const entry_points = {"main": "./src/entrypoint.js"};

  // Default to production settings
  env = env ? env : { debug: false };
  const mode = env.debug ? "development" : "production",
    min = mode == "production" || env.minify ? true : false,
    clean = mode == "production" || env.clean ? true : false,
    suffix = min ? ".min" : "";

  // Announce intentions
  console.log(
    "Building in " + mode + " mode (" +
      (clean ? "" : "no-") + "clean, " +
      (min ? "" : "no-") + "minify" +
      ")..."
  );

  // TerserWebpackPlugin's 'optimization' options
  var optimize_options = {
    minimize: min ? true : false,
    chunkIds: "named",
  };
  if (min) {
    optimize_options["minimizer"] = [
      new TerserPlugin({
        extractComments: {
          condition: /^\**!|@preserve|@license|@cc_on/i,
          filename: "extracted-comments.txt",
          banner: (licenseFile) => {
            return `License information can be found in ${licenseFile}`;
          },
        },
        terserOptions: {
          ecma: 2015,
          compress: min ? { drop_console: clean ? true : false, } : false,
          format: {
            semicolons: false,
            max_line_len: 110,
            comments: mode == "production" && min ? false : true,
          },
        },
      }),
      new CssMinimizerPlugin({
        parallel: true,
      }),
    ];
  }

  // Actual Webpack configuration
  return {
    entry: entry_points,
    target: 'web',
    mode: mode,
    optimization: optimize_options,
    devtool: (mode == 'development' ? 'eval-' : '') + 'source-map',
    output: {
      path: path.join(PROJECT_PATH, ASSET_PATH),
      filename: 'static/hpk.[name]' + suffix + '.js',
      chunkFilename: 'js/chunk.[id]' + suffix + '.js',
      hashDigestLength: 8,
    },
    module: {
      rules: [
        // JavaScript
        {
          test: /.js[x]$/,
          exclude: /(node_modules)/,
          use: {
            loader: "babel-loader",
            options: {
              presets: [
                [
                  "@babel/preset-env",
                  { targets: "defaults" },
                  //{"targets": "since 2015-03-10" }
                  //{ "useBuiltIns": "entry" }
                ],
                //"@babel/preset-react",
              ],
            },
          },
        },
        {
          test: /\.(s[ac]|c)ss$/,
          // test: /\.css$/i,
          include: path.join(PROJECT_PATH, "src/styles"),
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                publicPath: STATIC_PATH + "/",
              },
            },
            // {
            //   loader: "style-loader",
            // },
            {
              loader: "css-loader",
              options: {
                sourceMap: true,
                url: false,
              },
            },
            {
              loader: 'postcss-loader',
              options: {
                sourceMap: true,
                postcssOptions: {
                  plugins: [
                    "postcss-import",
                    require('tailwindcss')({
                      content: [
                        './src/styles/main.sass',
                        './src/**/*.html',
                        './src/**/*.js',
                      ],
                      theme: {
                        extend: {},
                      },
                      variants: {
                        extend: {},
                      },
                      plugins: [],
                    }),
                    "autoprefixer",
                    require('postcss-preset-env')({ stage: 3 }),
                  ],
                },
              },
            },
            {
              loader: "sass-loader",
              options: {
                implementation: require("sass"),
                sourceMap: true,
                sassOptions: {
                  includePaths: [path.join(PROJECT_PATH, "src/styles")],
                },
              },
            },
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: 'static/hpk.[name]' + suffix + '.css',
      }),
    ]
  }
};
