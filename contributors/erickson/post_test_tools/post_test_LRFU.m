function post_test

    clear; close all;
    directoryname = uigetdir('.', 'Select directory containing benchmark output');
    back = pwd;
    cd(directoryname);
    
    delete analysis.anagram.csv analysis.gcc.csv analysis.go.csv analysis.gzip.csv
    
    % Analyze all benchmark programs
    programs = 'gzip';
    
    ANALYZE_IPC  = true;
    ANALYZE_L1   = false;
    ANALYZE_L2   = true;
    
    ANALYZE_LRU  = true;
    ANALYZE_FIFO = false;
    ANALYZE_RAND = false;
    ANALYZE_LIP  = false;
    ANALYZE_BIP  = false;
    ANALYZE_DIP  = false;
    ANALYZE_LRFU = true;
    ANALYZE_PLRU = true;
    ANALYZE_GARP = false;   
    
    SAVE_FIGS    = true;

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
        
        Lambdas = cell(0);
        slot = 0;
        for idx = 1:size(file_list,1)
            
            fid = fopen(file_list(idx,:));
            filetext = fscanf(fid,'%s');
            fclose(fid);
            fstop = length(filetext)-15;  % arbitrary EOF 
            
            if length(filetext) < 10000
                continue; % simulation still in progress, skip this file
            end
            
            % Skip to simulation configuration
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
                    %repl_l2 = b(2:end);
                    repl_l2 = b(2);

                    cache_size_l2 = nsets_l2 * bsize_l2 * alloc_l2 * SCALE_TO_KB;
                	jdx_prev = jdx;
                    break;
                end
            end

            % Look for string: "sim_IPC"
            str1 = 'sim_IPC';
            for jdx = jdx_prev:fstop
                str2 = filetext(jdx:jdx+length(str1)-1);

                if strcmp(str1,str2)
                    kdx1 = jdx+length(str1);
                    kdx2 = jdx+length(str1);
                    while ~strcmp(filetext(kdx2),'#')
                        kdx2=kdx2+1;
                    end
                    kdx2=kdx2-1;
                    sim_ipc = str2double(filetext(kdx1:kdx2));
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
                    miss_rate_l1 = str2double(filetext(kdx1:kdx2));
                	jdx_prev = jdx;
                    break;
                end
            end
            
            % Look for string: "ul2.miss_rate"
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
                    miss_rate_l2 = str2double(filetext(kdx1:kdx2));
                    jdx_prev = jdx;
                    break;
                end
            end

            
            % Pack data from simout file into array for plots and csvs
            a = strfind(file_list(idx,:), '.T');
            [b c] = strtok(file_list(idx,a:end), '.');
            T_idx = str2double(b(2:end));
            
            if T_idx == 1
                slot = slot + 1;
            end
            
            % Convert miss rates into hit rates
            hit_rate_l1 = (1 - miss_rate_l1) * SCALE_TO_PERCENT;
            hit_rate_l2 = (1 - miss_rate_l2) * SCALE_TO_PERCENT;
            
            Data_Common = [T_idx ...                                    % Test case
                           cache_size_l1 nsets_l1 bsize_l1 alloc_l1 ... % L1 cache size
                           cache_size_l2 nsets_l2 bsize_l2 alloc_l2 ... % L2 cache size
                           hit_rate_l1 hit_rate_l2 sim_ipc];            % Performance
            flag = 0;
            for mdx = 1:length(Lambdas)
                if strcmp(c(2:end), Lambdas{mdx})
                    flag = 1;
                    break;
                end
            end
            if ( flag == 1 ) 
                Data_LRFU(T_idx,:,mdx) = Data_Common;
            elseif length(Lambdas) == 0
                Lambdas{1} = c(2:end);
                Data_LRFU(T_idx,:,1) = Data_Common;
            else
                Lambdas{mdx+1} = c(2:end);
                Data_LRFU(T_idx,:,mdx+1) = Data_Common;
            end
        end
        
        
        % Generate plots and csvs
        IPC_plot_str = '';
        L1_plot_str  = '';
        L2_plot_str  = '';
        leg_str = '';

        for pol_idx = size(Data_LRFU,3):-1:1
            
            IPC_plot_str = [IPC_plot_str 'Data_LRFU(:,6,' num2str(pol_idx) '), Data_LRFU(:,12,' num2str(pol_idx) '),''.-'', '];
            L1_plot_str  = [L1_plot_str 'Data_LRFU(:,2,' num2str(pol_idx) '), Data_LRFU(:,10,' num2str(pol_idx) '),''.-'', '];
            L2_plot_str  = [L2_plot_str 'Data_LRFU(:,6,' num2str(pol_idx) '), Data_LRFU(:,11,' num2str(pol_idx) '),''.-'', '];

            tmp = str2num(Lambdas{pol_idx}(8:end));
            %leg_str      = [leg_str '''\lambda = ' Lambdas{pol_idx}(8:end) ''','];
            leg_str      = [leg_str '''\lambda = ' num2str(tmp) ''','];
        end
                
        
        % generate plots of IPC, L1 and L2 miss rates versus cache size
        pow2s = [16 32 64 128 256 512 1024 2048 4096];
        
        if ANALYZE_IPC
            IPC_plot_str = ['figure; semilogx(', IPC_plot_str(1:end-2), '); hold all;'];
            eval(IPC_plot_str);
            title(['IPC (' program ')']); grid on; 
            xlabel('L2 Cache Size (KB)'); ylabel('Instructions Per Cycle (IPC)');
            
            h = findobj(gca,'Type','line'); 
            xs=get(h,'Xdata'); ys=get(h,'Ydata');
            min_xs = inf; max_xs = 0; min_ys = inf;  max_ys = 0;
            if (iscell(xs))  % in case more than one data set on plot
                for ndx = 1:size(xs,1)
                    min_xs = min(min(xs{ndx}), min_xs);
                    max_xs = max(max(xs{ndx}), max_xs);
                    min_ys = min(min(ys{ndx}), min_ys);
                    max_ys = max(max(ys{ndx}), max_ys);
                end
            else
                min_xs = min(xs); max_xs = max(xs);
                min_ys = min(ys); max_ys = max(ys);
            end
            
            min_xs = 256;
            min_ys = 1.82;max_ys=1.92;
            
            a = pow2s >= min_xs; b = pow2s <= max_xs; xticks = pow2s(a&b);
            set(gca,'XTick', xticks); 
            try xlim([min_xs max_xs]); end
            try ylim([min_ys max_ys]); end
            
            eval(['legend(' strrep(leg_str,'_','\_') '''Location'', ''Best'')']);
            hold off;
        end
        
        
        if ANALYZE_L2
            L2_plot_str = ['figure; semilogx(', L2_plot_str(1:end-2), '); hold all;'];
            eval(L2_plot_str);
            title(['L2 Cache Hit Rate (' program  ')']); grid on; 
            xlabel('L2 Cache Size (KB)'); ylabel('L2 Hit Rate');
            
            h = findobj(gca,'Type','line'); 
            xs=get(h,'Xdata'); ys=get(h,'Ydata');
            min_xs = inf; max_xs = 0; min_ys = inf;  max_ys = 100;
            if (iscell(xs))  % in case more than one data set on plot
                for ndx = 1:size(xs,1)
                    min_xs = min(min(xs{ndx}), min_xs);
                    max_xs = max(max(xs{ndx}), max_xs);
                    min_ys = min(min(ys{ndx}), min_ys);
                end
            else
                min_xs = min(xs); max_xs = max(xs);
                min_ys = min(ys);
            end
            
            min_xs = 256;
            min_ys = 91;max_ys = 99;
            
            a = pow2s >= min_xs; b = pow2s <= max_xs; xticks = pow2s(a&b);
            set(gca,'XTick', xticks); 
            try xlim([min_xs max_xs]); end
            %min_ys = floor(min_ys / 5)*5; % floor ys to increments of 5
            try ylim([min_ys max_ys]); end
            
            yticks = strread(num2str(get(gca,'YTick')),'%s');
            for sidx = 1:length(yticks); yticks{sidx} = [yticks{sidx} '%']; end
            set(gca,'YTickLabel', yticks);
            
            eval(['legend(' strrep(leg_str,'_','\_') '''Location'', ''Best'')']);
            hold off;
        end
        
        % Done w benchmark program
    end
    % Done w all benchmark programs
    
    if SAVE_FIGS
        hgsave(findobj(0,'type','figure'), 'analysis_figs');
    end
    
    cd(back);
end
