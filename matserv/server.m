% SERVER Write a message over the specified port
% 
% Usage - server(output_port, number_of_retries)
function server(output_port, number_of_retries)

    import java.net.ServerSocket
    import java.io.*
    import settings
    
    if settings.DEBUG
        disp('Welcome to MATHP, the MATLAB-Assisted Tool for Hypertext Preprocessing!')
        disp('This is the dev server.')
        disp(' ')
    end
    
    if (nargin < 2)
        number_of_retries = 20; % set to -1 for infinite
    end
    retry             = 0;

    server_socket  = [];
    output_socket  = [];

    while true

        retry = retry + 1;

        %try
            if ((number_of_retries > 0) && (retry > number_of_retries))
                fprintf(1, 'Too many retries\n');
                break;
            end
            %if settings.DEBUG
            %	fprintf(1, ['Try %d waiting for client to connect to this ' ...
            %	            'host on port : %d\n'], retry, output_port);
            %end
            
            % wait for 10 second for client to connect server socket

                server_socket = ServerSocket(output_port);
                server_socket.setReuseAddress(1)
                if settings.DEBUG && settings.TIMEOUT
                    server_socket.setSoTimeout(10000);
                end

                output_socket = server_socket.accept;
            
                input_stream=output_socket.getInputStream;
                temp=InputStreamReader(input_stream);
                in=BufferedReader(temp);
                %if settings.DEBUG
                %	fprintf(1, 'Client connected\n');
                %end
                
                line=char(in.readLine());
                linenumber=1;
                HttpRequest{1}=line; %#ok<AGROW>
                
                while line
                    line=char(in.readLine());
                    linenumber=linenumber+1;
                    HttpRequest{linenumber}=line;                %#ok<AGROW>
                end


            if exist('HttpRequest','var')
                [message,code]=process_request(HttpRequest);
                disp([datestr(now) ' "' HttpRequest{1} '" ' num2str(code)])
                clear HttpRequest
            end


                output_stream   = output_socket.getOutputStream;
                d_output_stream = DataOutputStream(output_stream);

                % output the data over the DataOutputStream
                % Convert to stream of bytes
                %if settings.DEBUG
                %    fprintf(1, 'Writing %d bytes\n', length(message))
                %end

                d_output_stream.write(uint8(message(1:end-2)), 0, length(message)-2);
                d_output_stream.flush();

                % clean up
                server_socket.close;
                output_socket.close;
                %break;

        %catch e
%             if ~isempty(server_socket)
%                 server_socket.close
%             end
% 
%             if ~isempty(output_socket)
%                 output_socket.close
%             end
%             
%             disp([datestr(now) ' Error: ' e.identifier])
%             
%             % pause before retrying
%             %pause(1);
        %end
    end
end
