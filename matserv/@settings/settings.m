classdef settings
    properties (Constant)
        ALLOWED_METHODS={'GET','HEAD'}
        HTML_ROOT_DIR='/home/chris/Desktop/mathp/htdocs'
        REDIR_NOSLASH=true
        ERROR_403=[settings.HTML_ROOT_DIR '/403.html']
        ERROR_404=[settings.HTML_ROOT_DIR '/404.html'] %#ok<REDEF>
        DEBUG=true
        TIMEOUT=false
        AUTO_BREAK=true
        TAG_END='>' % or ' />', for XML
        IMAGES_DIR=['/mathp_images/']
        OUTPUT_FORMAT='png'
    end
end
