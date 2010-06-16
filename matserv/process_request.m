function [HttpResponse,code]=process_request(HttpRequest)
    try
        import settings

        for linenumber=1:length(HttpRequest)
            if linenumber==1
                [method,urlpath,protocol]=firstparse(HttpRequest{linenumber});
            end
        end
        
        if ~exist('method','var') || isempty(method) || ~exist('urlpath','var') || isempty(urlpath) || ~exist('protocol','var') || isempty(protocol) || ~any(strcmp(method,settings.ALLOWED_METHODS))
            HttpResponse=make_response(make_header(protocol, 405));
            return
        end
        
        [localpath, newurlpath, code]=urls(urlpath);
        
        hr=make_header(protocol, code, localpath);
        
        if ~strcmp(method,'HEAD')
            hr{length(hr)+1}=addcontent(localpath);
        else
            hr{length(hr)+1}=''; % add extra linebreak
        end
        HttpResponse=make_response(hr);
        return
    catch e
        import settings
        code=500;
        hr=make_header(protocol, code, localpath);
        if settings.DEBUG && ~isempty(e.message) && ~isempty(e.identifier)
            hr{length(hr)+1}=e.identifier;
            hr{length(hr)+1}=e.message;
        else
            hr{length(hr)+1}='No error info available.';
        end
        HttpResponse=make_response(hr);
        return
    end
end


function HttpResponse=make_response(hr)

    HttpResponse=[hr{1} 13 10];
    for i=2:length(hr)
        HttpResponse=[HttpResponse hr{i} 13 10]; %#ok<AGROW>
    end

end


function [method,urlpath,protocol]=firstparse(line1)

    locations=findstr(line1,' ');

    if length(locations)==2
        method=line1(1:locations(1)-1);
        urlpath=line1(locations(1)+1:locations(2)-1);
        protocol=line1(locations(2)+1:end);
    else
        method='';
        urlpath='';
        protocol='';
    end

end


function content=addcontent(localpath)
% loads content and optionally runs mhp code



mathp_plot=@(varargin) insert_plot(varargin); %not private

privatestruct=struct('starts', [], ...
    'ends', [], ...
    'content', [],...
    'headpart',[],...
    'tailpart',[],...
    'T',[],...
    'breaks',[],...
    'localpath',localpath);
clear localpath

privatestruct.content=fread(fopen(privatestruct.localpath,'r'),inf,'ubit8',0,'n')';

privatestruct.starts=findstr(privatestruct.content, '<?mathp');
privatestruct.ends=findstr(privatestruct.content,'?>');

while ~isempty(privatestruct.starts)
    


    if length(privatestruct.starts)~=length(privatestruct.ends)
        error('MATHP:BadMATHPCode',['There was an error processing ' privatestruct.localpath ' due to bad <?mathp or ?> tag(s).'])
    end
    
    try
        privatestruct.T=evalc(char(privatestruct.content(privatestruct.starts(1)+7:privatestruct.ends(1)-1)));
    catch e
        import settings
        if settings.DEBUG
            rethrow(e)
        else
            error('MATHP:BadMATHPCode',['There was an error processing ' privatestruct.localpath ':' 10 e.identifier 10 e.message])
        end
    end

    
    if privatestruct.starts(1)-1<0
        privatestruct.headpart='';
    else
        privatestruct.headpart=privatestruct.content(1:privatestruct.starts(1)-1);
    end
    
    if privatestruct.ends(1)+2>length(privatestruct.content)
        privatestruct.tailpart='';
    else
        privatestruct.tailpart=privatestruct.content(privatestruct.ends(1)+2:end);
    end
    
    if settings.AUTO_BREAK
        privatestruct.breaks=findstr(privatestruct.T,char(10));
        if ~isempty(privatestruct.breaks)
            privatestruct.T = regexprep(privatestruct.T,char(10),['<br' settings.TAG_END char(10)]);
        end
    end
    
    privatestruct.content=[privatestruct.headpart privatestruct.T privatestruct.tailpart];
    privatestruct.starts=findstr(privatestruct.content, '<?mathp');
    privatestruct.ends=findstr(privatestruct.content,'?>');
end
content=privatestruct.content;
end

function insert_plot(varargin)

import settings

plot(varargin{:}{:}) % don't get why this is necessary...

[s,w]=system('uuidgen');

saveas(gcf, [settings.HTML_ROOT_DIR settings.IMAGES_DIR w(1:end-1)], settings.OUTPUT_FORMAT)

fprintf([settings.IMAGES_DIR w(1:end-1) '.' settings.OUTPUT_FORMAT])

end