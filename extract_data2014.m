cd('/Users/Sebastian/Desktop/xdisc/analysis/mod/BC')
folders=dir; folders=folders(2:end-1);folders=char(folders(4:end).name); 

for subs=1:size(folders,1)
    disp(strcat('### STARTING WITH SUBJECT: ', num2str(subs), ' ###'))
    cd(folders(subs,:))
    els=dir; els=char(els(3:end).name);
    for elecs=1:((length(dir)-2)/12)
        for conds=1:12
            cd(els(elecs*12-(12-conds),:))
            struct_img(:,:)=ft_read_mri('saverage.img');
            imgs(:,:,subs,elecs,conds)=struct_img.anatomy;
            cd ..
        end
    end
    cd ..
end