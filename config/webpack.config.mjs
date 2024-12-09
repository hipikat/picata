// TODO: add this all back in from picata...
//
// Use e.g. `webpack --env (debug|prod)[,minify][,clean]`, or
// everything will just default to clean, minified production mode.
//
// "clean" will strip comments and console.log() calls from the source,
//    and collect comments containing copyright or license information
//    into extracted-comments.txt.

// "minify" compresses files, inserts ".min" before filetype suffixes,
//    and creates map files. It takes longer than "nominify".
//
// "prod" cleans and minifies all files, while "debug" does not.
//

import path from "path";
import { fileURLToPath } from "url";
import MiniCssExtractPlugin from "mini-css-extract-plugin";
import CssMinimizerPlugin from "css-minimizer-webpack-plugin";
import TerserPlugin from "terser-webpack-plugin";

// Equivalent to __dirname in CommonJS
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROJECT_PATH = path.resolve(__dirname, "..");
const ASSET_PATH = process.env.ASSET_PATH || "build/webpack";
const STATIC_PATH = process.env.STATIC_PATH || "/static";

export default (env) => {
  const entry_points = { hpk: "./src/entrypoint.ts" };

  // Default to production settings
  env = env ? env : { debug: false };
  const mode = env.debug ? "development" : "production";
  const min = mode === "production" || env.minify ? true : false;
  const clean = mode === "production" || env.clean ? true : false;
  const suffix = min ? ".min" : "";

  // Announce intentions
  console.log(
    `Building in ${mode} mode (${clean ? "" : "no-"}clean, ${min ? "" : "no-"}minify)...`,
  );

  // TerserWebpackPlugin's 'optimization' options
  const optimize_options = {
    minimize: min,
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
          compress: min ? { drop_console: clean } : false,
          format: {
            semicolons: false,
            max_line_len: 110,
            comments: mode === "production" && min ? false : true,
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
    target: "web",
    mode,
    optimization: optimize_options,
    devtool: `${mode === "development" ? "eval-" : ""}source-map`,
    output: {
      path: path.join(PROJECT_PATH, ASSET_PATH),
      filename: `[name]${suffix}.js`,
      chunkFilename: `js/chunk.[id]${suffix}.js`,
      hashDigestLength: 8,
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: `[name]${suffix}.css`,
      }),
    ],
    module: {
      rules: [
        {
          test: /.jsx?$/,
          exclude: /(node_modules)/,
          use: {
            loader: "babel-loader",
            options: {
              presets: [["@babel/preset-env", { targets: "defaults" }]],
            },
          },
        },
        {
          test: /\.tsx?$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
            options: {
              presets: [
                ["@babel/preset-env", { targets: "defaults" }],
                "@babel/preset-typescript",
                "@babel/preset-react",
              ],
            },
          },
        },
        {
          test: /\.(s[ac]|c)ss$/,
          include: path.join(PROJECT_PATH, "src/styles"),
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                publicPath: `${STATIC_PATH}/`,
              },
            },
            {
              loader: "css-loader",
              options: {
                importLoaders: 2,
                sourceMap: true,
                url: false,
              },
            },
            {
              loader: "postcss-loader",
              options: {
                sourceMap: true,
                postcssOptions: {
                  plugins: [
                    "postcss-import",
                    "tailwindcss/nesting",
                    "tailwindcss",
                    [
                      "postcss-preset-env",
                      {
                        stage: 3,
                        features: { "nesting-rules": false },
                      },
                    ],
                    "autoprefixer",
                  ],
                },
              },
            },
            {
              loader: "sass-loader",
              options: {
                implementation: "sass",
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
  };
};
