%% Save_Tracking
% This function will save the cell array contents into separate tables
% It expects rat, red pup, green pup, blue pup
% Otherwise, throws error

function Save_Tracking(cellarray, dataname, basedir, RatID, timestamp, ext)


    for ii=1:length(cellarray)

            % Subset the table
 
  table_to_save = cellarray{ii};
  

            switch ii
                case 1
                    filename = strcat(RatID, '_', dataname, timestamp, ext);
                    writetable(table_to_save,fullfile(basedir, filename))

                case 2
                    filename = strcat(RatID, 'red_pup_' ,dataname, timestamp, ext);
                    writetable(table_to_save,fullfile(basedir, filename))
                    
                case 3
                    filename = strcat(RatID, 'green_pup_' ,dataname, timestamp, ext);
                    writetable(table_to_save,fullfile(basedir, filename))
                case 4
                    filename = strcat(RatID, 'blue_pup_' ,dataname, timestamp, ext);
                    writetable(table_to_save,fullfile(basedir, filename))
                otherwise
                error('Expecting only 4 tables within array.')

            end
    
    end
    
    sprintf('Saving completed!')
end