//
//  TemplateCarouselMessageTests.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest
@testable import LineSDK

extension TemplateCarouselMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "carousel",
          "columns": [
            {
              "thumbnailImageUrl": "https://sample.com",
              "title": "title 1",
              "text": "text 1",
              "actions": [
                {
                  "type": "uri",
                  "label": "action 1",
                  "uri": "http://action1.com/"
                }
              ]
            },
            {
              "thumbnailImageUrl": "https://another-sample.com",
              "text": "text 2",
              "actions": [
                {
                  "type": "uri",
                  "label": "action 2",
                  "uri": "http://action2.com/"
                },
                {
                  "type": "uri",
                  "label": "action 3",
                  "uri": "http://action3.com/"
                }
              ]
            }
          ]
        }
        """
        ]
    }
}

class TemplateCarouselMessageTests: XCTestCase {
    
    func testTemplateCarouselMessageEncoding() {
        let uriAction = TemplateMessageURIAction(label: "Cacnel", uri: URL(string: "scheme://action")!)
        let action = TemplateMessageAction.URI(uriAction)
        var column = TemplateCarouselMessage.Column(
            text: "hello",
            actions: [action],
            defaultAction: action,
            thumbnailImageURL: nil,
            imageBackgroundColor: .red)
        var message = TemplateCarouselMessage(columns: [column], imageAspectRatio: .square, imageContentMode: .aspectFill)
        
        column.text = "world"
        column.title = "a title"
        message.add(column: column)
        
        let dic = TemplateMessagePayload.carousel(message).json
        assertEqual(in: dic, forKey: "type", value: "carousel")
        assertEqual(in: dic, forKey: "imageAspectRatio", value: "square")
        assertEqual(in: dic, forKey: "imageSize", value: "cover")
        
        let columns = dic["columns"] as! [[String: Any]]
        XCTAssertEqual(columns.count, 2)
        
        let column1 = columns[0]
        assertEqual(in: column1, forKey: "text", value: "hello")
        XCTAssertNil(column1["title"])
        let actionsInColumn1 = column1["actions"] as! [[String: Any]]
        XCTAssertEqual(actionsInColumn1.count, 1)
        
        let column2 = columns[1]
        assertEqual(in: column2, forKey: "text", value: "world")
        assertEqual(in: column2, forKey: "title", value: "a title")
        let actionsInColumn2 = column2["actions"] as! [[String: Any]]
        XCTAssertEqual(actionsInColumn2.count, 1)
    }
    
    func testTemplateCarouselMessageDecoding() {
        let decoder = JSONDecoder()
        let result = TemplateCarouselMessage.samplesData
            .map { try! decoder.decode(TemplateMessagePayload.self, from: $0) }
            .map { $0.asCarouselMessage! }
        XCTAssertEqual(result[0].type, .carousel)
        XCTAssertEqual(result[0].imageAspectRatio, .rectangle)
        XCTAssertEqual(result[0].imageContentMode, .aspectFill)
        
        XCTAssertEqual(result[0].columns.count, 2)
        
        XCTAssertEqual(result[0].columns[0].text, "text 1")
        XCTAssertEqual(result[0].columns[0].title, "title 1")
        XCTAssertEqual(result[0].columns[0].actions.count, 1)
        
        XCTAssertEqual(result[0].columns[1].text, "text 2")
        XCTAssertNil(result[0].columns[1].title)
        XCTAssertEqual(result[0].columns[1].actions.count, 2)
    }
    
}
