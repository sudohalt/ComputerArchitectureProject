opts.showCode   = false;
opts.format     = 'pdf';
[a b] = fileparts(which('publish_post_test.m'));
opts.outputDir  = [a '\benchmarks'];
publish('post_test',opts);
