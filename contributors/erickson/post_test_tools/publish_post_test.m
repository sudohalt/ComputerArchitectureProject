opts.showCode   = false;
opts.format     = 'pdf';
%[a b] = fileparts(which('publish_post_test.m'));
opts.outputDir  = pwd;

%publish('post_test',opts);
publish('post_test_LRFU.m',opts);

movefile('post_test_LRFU.pdf', ['Post Test (LRFU) ' datestr(now,'yyyy-mm-dd HH.MM.SS.PM') '.pdf'])