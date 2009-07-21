#!/usr/bin/env python

# webkit2png - makes screenshots of webpages
# http://www.paranoidfish.org/projects/webkit2png
__version__ = "0.4"

# $Id: webkit2png-0.4 398 2004-09-24 18:40:49Z paul $

# Copyright (C) 2004 Paul Hammond
# Modified by Tymon 'teamon' Tobolski <http://teamon.eu>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
                
import sys

try:
  import Foundation
  import WebKit
  import AppKit
  import objc
  import re
except ImportError:
  print "Cannot find pyobjc library files.  Are you sure it is installed?"
  sys.exit() 


from optparse import OptionParser

class AppDelegate (Foundation.NSObject):
    # what happens when the app starts up
    def applicationDidFinishLaunching_(self, aNotification):
        webview = aNotification.object().windows()[0].contentView()
        webview.frameLoadDelegate().getURL(webview)

class WebkitLoad (Foundation.NSObject, WebKit.protocols.WebFrameLoadDelegate):
    # what happens if something goes wrong while loading
    def webView_didFailLoadWithError_forFrame_(self,webview,error,frame):
        print " something went wrong"
        self.getURL(webview)
    def webView_didFailProvisionalLoadWithError_forFrame_(self,webview,error,frame):
        print " something went wrong"
        self.getURL(webview)

    def makeFilename(self,URL,options):
       # make the filename
       if options.filename:
         filename = options.filename
       elif options.md5:
         try:
                import md5
         except ImportError:
                print "--md5 requires python md5 library"
                AppKit.NSApplication.sharedApplication().terminate_(None)
         filename = md5.new(URL).hexdigest()
       else:
         import re
         filename = re.sub('\W','',URL);
         filename = re.sub('^http','',filename);
       if options.datestamp:
         import time
         now = time.strftime("%Y%m%d")
         filename = now + "-" + filename
       import os
       dir = os.path.abspath(os.path.expanduser(options.dir))
       return os.path.join(dir,filename)

    def saveImages(self,bitmapdata,filename,options):
        # save the fullsize png
        if options.fullsize:
            bitmapdata.representationUsingType_properties_(AppKit.NSPNGFileType,None).writeToFile_atomically_(filename + "-full.png",objc.YES)

        if options.thumb or options.clipped:
            # work out how big the thumbnail is
            width = bitmapdata.pixelsWide()
            height = bitmapdata.pixelsHigh()
            thumbWidth = (width * options.scale)
            thumbHeight = (height * options.scale)

            # make the thumbnails in a scratch image
            scratch = AppKit.NSImage.alloc().initWithSize_(
                    Foundation.NSMakeSize(thumbWidth,thumbHeight))
            scratch.lockFocus()
            AppKit.NSGraphicsContext.currentContext().setImageInterpolation_(
                    AppKit.NSImageInterpolationHigh)
            thumbRect = Foundation.NSMakeRect(0.0, 0.0, thumbWidth, thumbHeight)
            clipRect = Foundation.NSMakeRect(0.0, 
                    thumbHeight-options.clipheight, 
                    options.clipwidth, options.clipheight)
            bitmapdata.drawInRect_(thumbRect)
            thumbOutput = AppKit.NSBitmapImageRep.alloc().initWithFocusedViewRect_(thumbRect)
            clipOutput = AppKit.NSBitmapImageRep.alloc().initWithFocusedViewRect_(clipRect)
            scratch.unlockFocus()
           
            # save the thumbnails as pngs 
            if options.thumb:
                thumbOutput.representationUsingType_properties_(
                        AppKit.NSPNGFileType,None
                    ).writeToFile_atomically_(filename + "-thumb.png",objc.YES)
            if options.clipped:
                clipOutput.representationUsingType_properties_(
                        AppKit.NSPNGFileType,None
                    ).writeToFile_atomically_(filename + "-clipped.png",objc.YES)

    def getURL(self,webview):
        if self.urls:
            if self.urls[0] == '-':
                url = sys.stdin.readline().rstrip()
                if not url: AppKit.NSApplication.sharedApplication().terminate_(None)
            else: 
                url = self.urls.pop(0)
        else:
            AppKit.NSApplication.sharedApplication().terminate_(None)
        if not re.search('^http', url):
            url = 'http://' + url
        print "Fetching " + url + " ...",
        self.resetWebview(webview)
        webview.mainFrame().loadRequest_(Foundation.NSURLRequest.requestWithURL_(Foundation.NSURL.URLWithString_(url)))
        if not webview.mainFrame().provisionalDataSource():
            print "not a proper url?"
            self.getURL(webview)
     
    def resetWebview(self,webview):
        rect = Foundation.NSMakeRect(0,0,self.options.initWidth,self.options.initHeight)
        webview.window().setContentSize_((self.options.initWidth,self.options.initHeight))
        webview.setFrame_(rect)
    
    def resizeWebview(self,view):
        view.window().display()
        view.window().setContentSize_(view.bounds().size)
        view.setFrame_(view.bounds())

    def captureView(self,view):
        view.lockFocus()
        bitmapdata = AppKit.NSBitmapImageRep.alloc()
        bitmapdata.initWithFocusedViewRect_(view.bounds())
        view.unlockFocus()
        return bitmapdata
 
    # what happens when the page has finished loading
    def webView_didFinishLoadForFrame_(self,webview,frame):
        # don't care about subframes
        if (frame == webview.mainFrame()):
            view = frame.frameView().documentView()
            
            self.resizeWebview(view)

            URL = frame.dataSource().initialRequest().URL().absoluteString()
            filename = self.makeFilename(URL, self.options) 

            bitmapdata = self.captureView(view)  
            self.saveImages(bitmapdata,filename,self.options)

            print "done"
            self.getURL(webview)


def main():

    # parse the command line
    usage = """%prog [options] [http://example.net/ ...]

examples:
%prog http://google.com/            # screengrab google
%prog -W 1000 -H 1000 http://google.com/ # bigger screengrab of google
%prog -T http://google.com/         # just the thumbnail screengrab
%prog -TF http://google.com/        # just thumbnail and fullsize grab
%prog -o foo http://google.com/     # save images as "foo-thumb.png" etc
%prog -                             # screengrab urls from stdin"""

    cmdparser = OptionParser(usage, version=("webkit2png "+__version__))
    # TODO: add quiet/verbose options
    cmdparser.add_option("-W", "--width",type="float",default=800.0,
       help="initial (and minimum) width of browser (default: 800)")
    cmdparser.add_option("-H", "--height",type="float",default=600.0,
       help="initial (and minimum) height of browser (default: 600)")
    cmdparser.add_option("--clipwidth",type="float",default=200.0,
       help="width of clipped thumbnail (default: 200)",
       metavar="WIDTH")
    cmdparser.add_option("--clipheight",type="float",default=150.0,
       help="height of clipped thumbnail (default: 150)",
       metavar="HEIGHT")
    cmdparser.add_option("-s", "--scale",type="float",default=0.25,
       help="scale factor for thumbnails (default: 0.25)")
    cmdparser.add_option("-m", "--md5", action="store_true",
       help="use md5 hash for filename (like del.icio.us)")
    cmdparser.add_option("-o", "--filename", type="string",default="",
       metavar="NAME", help="save images as NAME.png,NAME-thumb.png etc")
    cmdparser.add_option("-F", "--fullsize", action="store_true",
       help="only create fullsize screenshot")
    cmdparser.add_option("-T", "--thumb", action="store_true",
       help="only create thumbnail sreenshot")
    cmdparser.add_option("-C", "--clipped", action="store_true",
       help="only create clipped thumbnail screenshot")
    cmdparser.add_option("-d", "--datestamp", action="store_true",
       help="include date in filename")
    cmdparser.add_option("-D", "--dir",type="string",default="./",
       help="directory to place images into")
    (options, args) = cmdparser.parse_args()
    if len(args) == 0:
        cmdparser.print_help()
        return
    if options.filename:
        if len(args) != 1 or args[0] == "-":
          print "--filename option requires exactly one url"
          return
    if options.scale == 0:
      cmdparser.error("scale cannot be zero")
    # make sure we're outputing something
    if not (options.fullsize or options.thumb or options.clipped):
      options.fullsize = True
      options.thumb = True
      options.clipped = True
    # work out the initial size of the browser window
    #  (this might need to be larger so clipped image is right size)
    options.initWidth = (options.clipwidth / options.scale)
    options.initHeight = (options.clipheight / options.scale)
    if options.width>options.initWidth:
       options.initWidth = options.width
    if options.height>options.initHeight:
       options.initHeight = options.height
      
    app = AppKit.NSApplication.sharedApplication()
    
    # create an app delegate
    delegate = AppDelegate.alloc().init()
    AppKit.NSApp().setDelegate_(delegate)

    # create a window
    rect = Foundation.NSMakeRect(-16000,-16000,100,100)
    win = AppKit.NSWindow.alloc()
    win.initWithContentRect_styleMask_backing_defer_ (rect, 
            AppKit.NSBorderlessWindowMask, 2, 0)

    # create a webview object
    webview = WebKit.WebView.alloc()
    webview.initWithFrame_(rect)
    # turn off scrolling so the content is actually x wide and not x-15
    webview.mainFrame().frameView().setAllowsScrolling_(objc.NO)
    # add the webview to the window
    win.setContentView_(webview)
    
    # create a LoadDelegate
    loaddelegate = WebkitLoad.alloc().init()
    loaddelegate.options = options
    loaddelegate.urls = args
    webview.setFrameLoadDelegate_(loaddelegate)
    
    app.run()    

if __name__ == '__main__' : main()
