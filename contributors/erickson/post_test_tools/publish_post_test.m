opts.showCode   = false;
opts.format     = 'pdf';
[a b] = fileparts(which('publish_post_test.m'));
opts.outputDir  = pwd;

publish('post_test',opts);

movefile('post_test.pdf', ['Post Test ' datestr(now,'yyyy-mm-dd HH.MM.SS.PM') '.pdf'])