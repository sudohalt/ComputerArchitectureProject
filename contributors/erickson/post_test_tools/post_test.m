function post_test

    clear; close all;
    directoryname = uigetdir('.', 'Select directory containing benchmark output');
    back = pwd;
    cd(directoryname);
    
    % Analyze all benchmark programs
    programs = ['anagram'; ...
                'gcc    '; ...
                'go     '; ...
                'gzip   '];
    
    ANALYZE_L1       = false;
    ANALYZE_L2       = true;
    SAVE_FIGS        = true;

    SCALE_TO_MB      = 2^-20;   % 1/1,048,576 bytes
    SCALE_TO_KB      = 2^-10;   % 1/1,024 bytes
    SIZE_32KB        = 32;      % used for plots
    SIZE_256KB       = 256;     % used for plots
    SIZE_1024KB      = 1024;    % used for plots
    SCALE_TO_PERCENT = 100;     % used for miss rates

     for prog_idx = 1:size(programs,1)
        
        program   = programs(prog_idx,:); program(program==' ') = '';
        file_list = ls([program '.simout.*']);
        clear Data_*

        [fullpath, foo]   = (fileparts(pwd));
        [foo, benchmarks] = (fileparts(fullpath));
        for idx = 1:size(file_list,1)

            fid = fopen(file_list(idx,:));
            filetext = fscanf(fid,'%s');
            fclose(fid);
            fstop = length(filetext)-15;  % arbitrary EOF 
            
            % Skip to statistics
            str1 = '#-config';
            for jdx = 1:fstop
                str2 = filetext(jdx:jdx+length(str1)-1);
                if strcmp(str1,str2)
                    jdx_prev = jdx;
                    break;
                end
            end

            % Look for cache config string: "-cache:dl1 dl1:a:b:c:d"
            str1 = '-cache:dl1dl1:';
            for jdx = jdx_prev:fstop
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while (~strcmp(filetext(kdx2),'#'))
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
                    jdx_prev = jdx;
                    break;
                end
            end
                
            % Look for cache config string: "-cache:dl2 ul1:a:b:c:d"
            str1 = '-cache:dl2ul2:';
            for jdx = jdx_prev:fstop    
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
                	jdx_prev = jdx;
                    break;
                end
            end

            % Look for string: "dl1.miss_rate"
            str1 = 'dl1.miss_rate';
            for jdx = jdx_prev:fstop
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    miss_rate_l1 = str2double(filetext(kdx1:kdx2)) * SCALE_TO_PERCENT;
                	jdx_prev = jdx;
                    break;
                end
            end

            % Look for string: "dl1.miss_rate"
            str1 = 'ul2.miss_rate';
            for jdx = jdx_prev:fstop
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    miss_rate_l2 = str2double(filetext(kdx1:kdx2)) * SCALE_TO_PERCENT;
                    jdx_prev = jdx;
                    break;
                end
            end

            
            % Pack data from simout file into array for plots and csvs
            a = strfind(file_list(idx,:), '.T');
            [b c] = strtok(file_list(idx,a:end), '.');
            T_idx = str2double(b(2:end));
            
            Data_Common = [T_idx cache_size_l1 nsets_l1 bsize_l1 alloc_l1 ...
                                 cache_size_l2 nsets_l2 bsize_l2 alloc_l2];

            if strcmp(repl_l2,'l')
                Data_LRU(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            elseif strcmp(repl_l2,'a')
                Data_LRFU(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            elseif strcmp(repl_l2,'x')
                Data_LIP(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            elseif strcmp(repl_l2,'b')
                Data_BIP(T_idx,:) = [Data_Common miss_rate_l1 miss_rate_l2];
            end
        end
        
        
        % Generate plots and csvs
        L1_plot_str = '';
        L2_plot_str = '';
        leg_str = '';
        csv_out = ['analysis.' program '.csv'];
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
                fprintf(fid, '%s\n', [csv_hdr ',',pol(6:end),' DL1_miss_rate (%),',pol(6:end),' DL2_miss_rate (%)']);
                fclose(fid);
                eval(['dlmwrite(csv_out,', pol, ',''-append'')']);
            end
        end
                
        
        % generate plots of L1 and L2 miss rates versus cache size
        pow2s = [16 32 64 128 256 512 1024 2048 4096];
        
        if ANALYZE_L1
            L1_plot_str = ['figure;hold all;plot(', L1_plot_str(1:end-2), ')'];
            eval(L1_plot_str);
            title([program ': L1 Cache Miss Rate vs Cache Size']); grid on; 
            xlabel('L1 Cache Size (KB)'); ylabel('L1 Miss Rate (%)'); 
            ys = ylim; ymax = ys(2);
            h = findobj(gca,'Type','line'); xs=get(h,'Xdata');
            a = pow2s >= min(xs); b = pow2s <= max(xs); xticks = pow2s(a&b);
            plot([SIZE_32KB,SIZE_32KB], [0,ymax], 'k--'); ylim([0,ymax]);
            set(gca,'XTick', xticks); xlim([min(xs) max(xs)]);
            eval(['legend(' leg_str '''32KB'')'])
            hold off;
        end
        
        if ANALYZE_L2
            L2_plot_str = ['figure;hold all;plot(', L2_plot_str(1:end-2), ')'];
            eval(L2_plot_str);
            title([program ': L2 Cache Miss Rate vs Cache Size']); grid on; 
            xlabel('L2 Cache Size (KB)'); ylabel('L2 Miss Rate (%)'); 
            ys = ylim; ymax = ys(2);
            h = findobj(gca,'Type','line'); xs=get(h,'Xdata');
            a = pow2s >= min(xs); b = pow2s <= max(xs); xticks = pow2s(a&b);
            plot([SIZE_1024KB,SIZE_1024KB], [0,ymax], 'k--'); ylim([0,ymax]);
            set(gca,'XTick', xticks); xlim([min(xs) max(xs)]);
            eval(['legend(' leg_str '''1024KB'')'])
            hold off;
        end
        
        % Done w benchmark program
    end
    % Done w all benchmark programs
    
    if SAVE_FIGS
        if ANALYZE_L1 && ANALYZE_L2
            hgsave([8 7 6 5 4 3 2 1], 'analysis_figs');
        else
            hgsave([4 3 2 1], 'analysis_figs');
        end
    end
    cd(back);
end
