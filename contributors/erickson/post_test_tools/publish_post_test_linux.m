opts.showCode = false;
opts.format = 'pdf';
[a b] = fileparts(which('publish_post_test_linux.m'));
opts.outputDir = pwd;
publish('post_test_linux',opts);
movefile('post_test_linux.pdf', ['Post Test ' datestr(now,'yyyy-mm-dd HH.MM.SS.PM') '.pdf'])
