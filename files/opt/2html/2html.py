import os, sys, logging, traceback, magic, subprocess, shutil, datetime

reload(sys)
sys.setdefaultencoding('utf8')

SOFFICE = '/usr/bin/soffice'
UNOCONV = '/usr/bin/unoconv'
PDF2HTMLEX = '/usr/local/bin/pdf2htmlEX'
UNCOMPRESS = '/usr/local/bin/7z'

office_types = ['msword', 'vnd.ms-', 'vnd.oasis.opendocument',
    'vnd.openxmlformats-officedocument']
pdf_types = ['pdf', 'postscript']
image_types = ['tiff', 'png', 'jpeg']
compressed_types = ['x-7z', 'x-bzip2', 'x-compress', 'x-gzip', 'x-rar',
    'x-tar', 'x-xz', 'zip']
BUFFER_SIZE = 16000
MAX_DEPTH = 10
LOGGER_INFO="2HTML"

def __setup_logging(filename, level=logging.DEBUG, format_t=None, name=None):
    _HEAD_FMT = """<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="refresh" content="5" >
    <style type="text/css">
    table td {vertical-align: top;}
    .container {border : 1px dotted #818286; padding : 5px;
    margin: 5px; width: 1000px; font-family: Corrier; font-size: 14px;
    background-color : #292929;}
    .CRITICAL {color: #EE1100; font-weight: bold}
    .ERROR {color: #EE1100; font-weight: bold}
    .WARNING {color: #FFCC00; font-weight: bold}
    .INFO {color: #008000; font-weight: bold}
    .DEBUG {color: #CCA0A0;}
    </style>"""
    _TAIL_FMT = """<pre>
     _____   _   __   _   _   _____   _   _
    |  ___| | | |  \ | | | | /  ___/ | | | |
    | |__   | | |   \| | | | | |___  | |_| |
    |  __|  | | | |\   | | | \___  \ |  _  |
    | |     | | | | \  | | |  ___| | | | | |
    |_|     |_| |_|  \_| |_| /_____/ |_| |_|
    </pre>"""
    _INFO_MSG_FMT = "<div class=\"container\"><table><tr><td width=\"170\" style=\"color: #FFFFFF;\"><b>%(asctime)s</b></td><td class=\"%(levelname)s\"><div>%(message)s</div></td></tr></table></div>"
    _DEF_MSG_FMT = "%(asctime)s - %(message)s"

    class TOHTMLFileHandler(logging.FileHandler):
        def __init__(self, *args):
            super(TOHTMLFileHandler, self).__init__(*args)
            self.stream.write(_HEAD_FMT)

        def close(self):
            self.stream.write(_TAIL_FMT)
            super(TOHTMLFileHandler, self).close()
    if name is None:
        logger = logging.getLogger()
    else:
        logger = logging.getLogger(name)

    logger.setLevel(level)

    if format_t == 'html':
        hdlr = TOHTMLFileHandler(filename)
        frmtr = logging.Formatter(_INFO_MSG_FMT, '%Y-%m-%d %H:%M:%S')
        hdlr.setFormatter(frmtr)
    else:
        hdlr = logging.FileHandler(filename)
        frmtr = logging.Formatter(_DEF_MSG_FMT, '%Y-%m-%d %H:%M:%S')
        hdlr.setFormatter(frmtr)

    logger.addHandler(hdlr)

def __get_mime_type(filename):
    mime_type = 'unconverted'
    mt_dict = {'main': '', 'sub' : ''}
    try:
        mt = magic.from_file(filename, mime=True)
        if mt and '/' in mt:
            mt_dict['main'], mt_dict['sub'] = mt.split('/')
        if mt_dict['main'] == 'application':
            for x in pdf_types:
                if x in mt_dict['sub']:
                    return 'pdf'

            for x in office_types:
                if x in mt_dict['sub']:
                    return 'office'

            for x in compressed_types:
                if x in mt_dict['sub']:
                    return 'archive'

        if mt_dict['main'] == 'image':
            for x in image_types:
                if x in mt_dict['sub']:
                    return 'image'
    except:
        tb = traceback.format_exc()
        e = sys.exc_info()
        logging.error("Error when getting mime type: " + str(e))
        logging.error(str(tb))

    return mime_type

def __convert_file(srcfile, dst_dir, cmd_type='copy', new_ext='copy', cmd_args=None):
    try:
        if not os.path.exists(dst_dir):
            os.makedirs(dst_dir)
        src_fname = str(os.path.basename(srcfile))
        outputfname = os.path.join(dst_dir, src_fname + '.' + new_ext)
        if cmd_type == 'call':
            subprocess.call(cmd_args, stderr=logging.getLogger().handlers[0].stream)
        else:
            with open(srcfile, 'rb') as fsrc:
                with open(outputfname, 'wb+') as fdest:
                    shutil.copyfileobj(fsrc, fdest, BUFFER_SIZE)

        msg = 'File converted: ' + srcfile + ' => ' + outputfname
        logging.getLogger().info(msg)
        logging.getLogger(LOGGER_INFO).info(msg)
    except:
        tb = traceback.format_exc()
        e = sys.exc_info()
        logging.error("***ERROR*** in processing file: " + srcfile)
        logging.getLogger(LOGGER_INFO).error("***ERROR*** in processing file: " + srcfile)
        logging.error(str(e))
        logging.error(str(tb))

def __unarchive(srcfile, dst_dir, level):
    try:
        if not os.path.exists(dst_dir):
            os.makedirs(dst_dir)

        subprocess.call([UNCOMPRESS, 'x', srcfile, '-o' + dst_dir, '-y'],
                        stdout=logging.getLogger().handlers[0].stream)
        msg = '7z Uncompressed file: ' + srcfile + ' => ' + dst_dir
        logging.getLogger().info(msg)
        ogging.getLogger(LOGGER_INFO).info(msg)
    except:
        tb = traceback.format_exc()
        e = sys.exc_info()
        logging.error("***ERROR*** in processing file: " + srcfile)
        logging.error(str(e))
        logging.error(str(tb))

def tohtml_file(src_file, dst_dir, level):
    i = os.path.basename(src_file)
    mt = __get_mime_type(src_file)
    if mt == 'pdf':
        __convert_file(src_file, dst_dir, 'call', 'html', [PDF2HTMLEX, '--dest-dir', dst_dir, src_file])

    if mt == 'office' or mt == 'image':
        tmpname = 'tmp.' + datetime.datetime.now().strftime("%y%m%d%H%M%S")
        tmp_src_dir = os.path.join(dst_dir, i + '.' + tmpname)
        __convert_file(src_file, tmp_src_dir, 'call', 'pdf', [SOFFICE, '--headless', '--convert-to', 'pdf:writer_pdf_Export', '--outdir', tmp_src_dir, src_file])
        tohtml_dir(tmp_src_dir, dst_dir, level)

        if os.path.exists(tmp_src_dir):
            shutil.rmtree(tmp_src_dir)

    if mt == 'archive':
        n_dst_dir = os.path.join(dst_dir, i)
        tmpname = 'tmp.' + datetime.datetime.now().strftime("%y%m%d%H%M%S")
        tmp_src_dir = os.path.join(dst_dir, i + '.' + tmpname)
        __unarchive(src_file, tmp_src_dir, level)
        tohtml_dir(tmp_src_dir, n_dst_dir, level)

        if os.path.exists(tmp_src_dir):
            shutil.rmtree(tmp_src_dir)

    if mt == 'unconverted':
        __convert_file(src_file, dst_dir)

def tohtml_dir(src_dir, dst_dir, level):
    if level < 0:
        logging.error("Process reached the max depth!!")
        logging.error("Source: " + src_dir)
        logging.error("####### *** #######")

    for i in os.listdir(src_dir):
        fname=os.path.join(src_dir, i)
        if str(i).startswith('.'):
            logging.getLogger().info('### Ignoring file => ' + fname)
            continue

        if os.path.islink(fname):
            logging.getLogger().info('### Ignoring link => ' + fname)
            continue

        elif os.path.isdir(fname):
            ndst_dir = os.path.join(dst_dir, i)
            if not os.path.exists(ndst_dir):
                os.makedirs(ndst_dir)
            logging.getLogger(LOGGER_INFO).info('Processing directory: ' + fname)
            tohtml_dir(fname, ndst_dir, level - 1)

        elif os.path.isfile(fname):
            logging.getLogger(LOGGER_INFO).info('Processing file: ' + fname)
            tohtml_file(fname, dst_dir, level)

def process_file(src, dst=None):
    dt_now = datetime.datetime.now().strftime("%y%m%d%H%M%S")
    is_file = False

    if dst is None:
        src_dir = os.path.dirname(src)
        dst = src_dir + '/2html_output_' + dt_now
        try:
            if not os.path.exists(dst):
                os.makedirs(dst)
        except:
            print str(sys.exc_info())
            exit()
        is_file = True

    log_debug = dst + '/' + '2html.debug.' + dt_now + '.log'
    log_info = dst + '/' + '2html.info.' + dt_now + '.html'

    __setup_logging(os.path.normpath(log_debug))
    __setup_logging(os.path.normpath(log_info), logging.INFO, 'html', LOGGER_INFO)

    try:
        if is_file:
            tohtml_file(src, dst, MAX_DEPTH)
        else:
            tohtml_dir(src, dst, MAX_DEPTH)
    except:
        tb = traceback.format_exc()
        e = sys.exc_info()
        logging.error("Unexpected error: " + str(e))
        logging.error(str(tb))
        logging.getLogger(LOGGER_INFO).info("### Unexpected ERROR!!! ###: " + str(e))

if __name__ == '__main__':
    if len(sys.argv) == 3:
        src_dir = os.path.normpath(sys.argv[1])
        dst_dir = os.path.normpath(sys.argv[2])

        if not os.path.isdir(src_dir) or not os.path.isdir(dst_dir):
            print "First and second argument must be a directory!"
            exit()
        process_file(src_dir, dst_dir)

    elif len(sys.argv) == 2:
        src_file = os.path.normpath(sys.argv[1])

        if not os.path.isfile(src_file):
            print "Argument must be a file!"
            exit()
        process_file(src_file)

    else:
        print "Missing arguments!"
        print "Use: python " + sys.argv[0] + " [input_dir output_dir | input_file]"
        exit()
