function [localpath, newurlpath, code]=urls(urlpath)

import settings

question=findstr(urlpath,'?');
if question
    getvars=urlpath(question+1:end); %#ok<NASGU>
    urlpath=urlpath(1:question-1);
end

localpath=[settings.HTML_ROOT_DIR urlpath];


%% Prevent '..' from going to a directory higher than HTML_ROOT_DIR
% Compares the paths

if exist(localpath,'dir')

    currentdir=cd(localpath);

    foo=pwd;

    cd(currentdir)

    if ~strncmp(settings.HTML_ROOT_DIR, foo, length(settings.HTML_ROOT_DIR))
        localpath=settings.ERROR_403;
        newurlpath=urlpath;
        code=403;
        return
    end
end

%% Redirect http://example.com/foo to http://example.com/foo/

if settings.REDIR_NOSLASH && urlpath(end)~='/' && exist(localpath,'file')~=2 && exist(localpath,'dir')
    newurlpath=[urlpath '/'];   
    localpath=[localpath '/'];
    code=301;
    return
end

%% Display http://example.com/index.html if http://example.com/ requested

if exist(localpath,'file')~=2 && exist([localpath 'index.html'], 'file')==2
    localpath=[localpath 'index.html'];
    newurlpath=urlpath;
    code=200;
    return
end

%% Get the file otherwise

if exist(localpath,'file')
    newurlpath=urlpath;
    code=200;
else
    newurlpath=urlpath;
    localpath=settings.ERROR_404;
    code=404;
end