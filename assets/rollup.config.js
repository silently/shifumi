import babel from 'rollup-plugin-babel';
import commonjs from 'rollup-plugin-commonjs';
import replace from 'rollup-plugin-replace';
import nodeResolve from 'rollup-plugin-node-resolve';
import uglify from 'rollup-plugin-uglify-es';

const ENV = process.env.NODE_ENV || 'dev';

export default [
  {
    input: 'js/sw/index.js',
    output: {
      file: '../priv/static/sw.js',
      sourcemap: ENV !== 'production',
      format: 'iife'
    },
    plugins: [
      ENV === 'production' && uglify()
    ],
    watch: {
      include: ['js/sw/**']
    }
  },
  {
    input: 'js/app/index.js',
    output: {
      file: '../priv/static/js/app.js',
      sourcemap: ENV !== 'production',
      format: 'iife'
    },
    plugins: [
      nodeResolve(),
      replace({
        'process.env.NODE_ENV': JSON.stringify(ENV),
        'DEBUG_FLAG': ENV === 'dev'
      }),
      commonjs({
        include: ['node_modules/**', '../deps/**'],
        namedExports: {
          '../deps/phoenix/priv/static/phoenix.js': ['Presence', 'Socket'],
          './node_modules/react/index.js': ['createElement', 'Children', 'Component']
        }
      }),
      babel({
        // only transpile our source code
        exclude: ['node_modules/**', '../deps/**']
      }),
      ENV === 'production' && uglify({
        compress: {
          // reduce_vars conflicts with redux
          reduce_vars: false
        }
      })
    ],
    watch: {
      include: ['js/app/**', 'js/sw/**']
    }
  }
]
