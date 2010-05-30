function hr=make_header(protocol, code, localpath)

hr{1}=[protocol ' ' num2str(code) ' ' code_lookup(code)];
hr{2}=['Date: ' datestr(now,'ddd, dd mmm yyyy HH:MM:SS')];

if nargin >=3
    D=dir(localpath);

    Dnametemp=D.name(end:-1:1);

    locations=findstr(Dnametemp,'.');

    location=locations(1);

    extension=Dnametemp(location-1:-1:1);

    try
        import mimetypes
        mimetype=eval(['mimetypes.' extension]);
    catch %#ok<CTCH>
        warning('MATHP:UnknownMIMEType',['The mimetype for ' extension ' is unknown'])
        mimetype='application/x-octet-stream';
    end
end

hr{length(hr)+1}=['Content-Type: ' mimetype '; charset=utf-8'];
hr{length(hr)+1}='Connection: close';
hr{length(hr)+1}='';


end


function cl=code_lookup(code)

    switch code
        case 200
            cl='OK';
        case 403
            cl='Forbidden';
        case 404
            cl='Not Found';
        case 500
            cl='Internal Server Error';
        otherwise
            error('MATHP:UnknownError',['wtf status code was ' char(code)])
    end

end
    
