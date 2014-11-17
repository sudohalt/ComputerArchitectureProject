function post_test

    clear; close all;
    directoryname = uigetdir('.', 'Select directory containing anagram, gcc, etc folders');
    back=pwd;
    cd(directoryname);
    
    % selected benchmark directory, analyze all programs
    dir_list = ['anagram'; ...
                'gcc    '; ...
                'go     '; ...
                'gzip   '];
    dirs     = size(dir_list,1);

    SCALE_TO_MB = 2^-20;    % 1/1,048,576 bytes
    SCALE_TO_KB = 2^-10;    % 1/1,048,576 bytes
    SIZE_32KB   = 32; 
    SIZE_256KB  = 256;
    SCALE_TO_PERCENT = 100; % for miss rates

    for dir_idx = 1:dirs

        cd(dir_list(dir_idx,:))
        file_list = ls('*.simout.*');

        [fullpath, program]    = (fileparts(pwd));
        [pathpath, benchmarks] = (fileparts(fullpath));
        for idx = 1:size(file_list,1)

            fid = fopen(file_list(idx,:));
            filetext = fscanf(fid,'%s');
            fclose(fid);

            for jdx = 1:(length(filetext)-15)

                str1 = 'dl1:';
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    str=filetext(kdx1:kdx2);
                    [a, b]= strtok(str,':');
                    nsets_l1 = str2double(a);
                    [a, b]= strtok(b,':');
                    bsize_l1 = str2double(a);
                    [a, b]= strtok(b,':');
                    alloc_l1 = str2double(a);
                    repl_l1 = b(2:end);

                    cache_size_l1 = nsets_l1 * bsize_l1 * alloc_l1 * SCALE_TO_KB;
                end

                str1 = 'ul2:';
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    str=filetext(kdx1:kdx2);
                    [a, b]= strtok(str,':');
                    nsets_l2 = str2double(a);
                    [a, b]= strtok(b,':');
                    bsize_l2 = str2double(a);
                    [a, b]= strtok(b,':');
                    alloc_l2 = str2double(a);
                    repl_l2 = b(2:end);

                    cache_size_l2 = nsets_l2 * bsize_l2 * alloc_l2 * SCALE_TO_KB;
                end

                str1 = 'dl1.miss_rate';
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    miss_rate_l1 = str2double(filetext(kdx1:kdx2)) * SCALE_TO_PERCENT;
                end

                str1 = 'ul2.miss_rate';
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    miss_rate_l2 = str2double(filetext(kdx1:kdx2)) * SCALE_TO_PERCENT;
                end
            end

            a = strfind(file_list(idx,:), '.T');
            [b c] = strtok(file_list(idx,a:end), '_');
            T_idx = str2double(b(3:end));
            
            Data_Common = [T_idx cache_size_l1 nsets_l1 bsize_l1 alloc_l1 ...
                                 cache_size_l2 nsets_l2 bsize_l2 alloc_l2];

            if strcmp(repl_l1,'l')
                Data_LRU(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            elseif strcmp(repl_l1,'x')
                Data_LIP(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            elseif strcmp(repl_l1,'b')
                Data_BIP(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            end
        end
        
        
        %% assemble data to plot and write to csv
        L1_plot_str = '';
        L2_plot_str = '';
        leg_str = '';
        csv_out = [fullpath '\' program '.' benchmarks '.csv'];
        csv_hdr = 'Test_Case, DL1_cache_size, DL1_nsets, DL1_bsize, DL1_alloc, DL2_cache_size, DL2_nsets, DL2_bsize, DL2_alloc';
        
        repl_pols = ['LRU '; 'FIFO'; 'RAND'; 'LIP '; 'BIP '; 'DIP '; 'LRFU'; 'GARP'];
        for pol_idx = 1:size(repl_pols,1)
            
            pol = ['Data_' repl_pols(pol_idx,:)]; pol(pol==' ') = '';
            if exist(pol,'var')
                L1_plot_str = [L1_plot_str pol '(:,2), ' pol '(:,10),''.-'', '];
                L2_plot_str = [L2_plot_str pol '(:,6), ' pol '(:,11),''.-'', '];
                leg_str = [leg_str '''' pol(6:end) ''','];

                % write data to csv
                fid = fopen(csv_out,'a');
                fprintf(fid, '%s\n', [csv_hdr ',',pol(6:end),' DL1_miss_rate (%),',pol(6:end),' LRU DL2_miss_rate (%)']);
                fclose(fid);
                eval(['dlmwrite(csv_out,', pol, ',''-append'')']);
            end
        end
                
        
        % generate plots of L1 and L2 miss rates versus cache size
        pow2s = [16 32 64 128 256 512 1024 2014 4096];
        
        L1_plot_str = ['figure;hold all;plot(', L1_plot_str(1:end-2), ')'];
        eval(L1_plot_str);
        title([program ': L1 Cache Miss Rate vs Cache Size']); grid on; 
        xlabel('L1 Cache Size (KB)'); ylabel('L1 Miss Rate (%)'); 
        ys = ylim; ymax = ys(2);
        xs = xlim; a = pow2s >= xs(1); b = pow2s <= xs(2); xticks = pow2s(a&b);
        plot([SIZE_32KB,SIZE_32KB], [0,ymax], 'k--'); ylim([0,ymax]);
        set(gca,'XTick', xticks);
        eval(['legend(' leg_str '''32KB'')'])
        hold off;

        L2_plot_str = ['figure;hold all;plot(', L2_plot_str(1:end-2), ')'];
        eval(L2_plot_str);
        title([program ': L2 Cache Miss Rate vs Cache Size']); grid on; 
        xlabel('L2 Cache Size (KB)'); ylabel('L2 Miss Rate (%)'); 
        ys = ylim; ymax = ys(2);
        xs = xlim; a = pow2s >= xs(1); b = pow2s <= xs(2); xticks = pow2s(a&b);
        plot([SIZE_256KB,SIZE_256KB], [0,ymax], 'k--'); ylim([0,ymax]);
        set(gca,'XTick', xticks);
        eval(['legend(' leg_str '''256KB'')'])
        hold off;
        
        
        cd ..
    end
end
