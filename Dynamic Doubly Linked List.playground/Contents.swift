//: A UIKit based Playground for presenting user interface

//
//  XC90 Dynamic Doubly Linked List.playground
//
//  Created by Andrew L. Jaffee on 9/15/2018.
//
/*
 
 Copyright (c) 2018 Andrew L. Jaffee, microIT Infrastructure, LLC, and iosbrain.com.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/

import UIKit
import PlaygroundSupport

protocol NodeProtocol: class {
    associatedtype AnyType
    
    var tag: String? { get }
    var payload: AnyType? { get set }
    var next: Self? { get set }
    var previous: Self? { get set }
    
    init(with payload: AnyType, named tag: String)
}

final class Node<AnyType>: NodeProtocol {
    
    var tag: String?
    var payload: AnyType?
    var next: Node<AnyType>?
    var previous: Node<AnyType>?
    
    init(with payload: AnyType, named tag: String) {
        
        // Stores a reference when using classes;
        // stores a copy when using value types.
        self.payload = payload
        self.tag = tag
        
        print("Allocating node tagged: [\(tag)]")
        
    }
    
    deinit {
        print("Deallocating node tagged: [\(tag!)]")
    }
    
} // end class Node

protocol LinkedListProtocol {
    
    associatedtype AnyType
    
    var head: Node<AnyType>? { get set }
    var tail: Node<AnyType>? { get set }
    mutating func append(_ newNode: Node<AnyType>)
    mutating func insert(_ newNode: Node<AnyType>, after nodeWithTag: String)
    mutating func delete(_ node: Node<AnyType>)
    func showAll()
    func showAllInReverse()
    subscript(tag: String) -> Node<AnyType>? { get }
    func prepareForDealloc()
    
}

extension LinkedListProtocol {
    
    mutating func append(_ newNode: Node<AnyType>) {
        
        if let tailNode = tail {
            
            print("Appending [\(newNode.tag!)] to tail")
            tailNode.next = newNode
            newNode.previous = tailNode
            
        }
        else {
            
            print("Appending [\(newNode.tag!)] to head")
            head = newNode
            
        } // end else
        
        tail = newNode
        
    } // end func append
    
    mutating func insert(_ newNode: Node<AnyType>, after nodeWithTag: String) {
        
        if head == nil {
            return
        }
            
        else {
            
            var currentNode = head
            
            while currentNode != nil {
                
                if nodeWithTag == currentNode?.tag {
                    
                    // If the current node with matching tag is
                    // NOT the tail...
                    if currentNode?.next != nil {
                        
                        // ... then insert new node "after"
                        // the current node.
                        let newNextNode = currentNode?.next
                        currentNode?.next = newNode
                        newNextNode?.previous = newNode
                        newNode.previous = currentNode
                        newNode.next = newNextNode
                        currentNode = nil
                        print("Inserting [\(newNode.tag!)]")
                        
                    }
                    else { // Append to list with single head
                           // (which means tail = head).
                        
                        append(newNode)
                        currentNode = nil
                        
                    }
                    
                } // end if nodeWithTag == currentNode?.tag
                    
                else {
                    currentNode = currentNode?.next
                }
                
            } // end while
            
        } // end else
        
    } // end func insert
    
    mutating func delete(_ node: Node<AnyType>) {
        
        // Remove the head?
        if node.previous == nil {
            
            if let nodeAfterDeleted = node.next {
                
                print("Delete head [\(node.tag)] with followers")
                nodeAfterDeleted.previous = nil
                head?.next = nil
                head = nil
                head = nodeAfterDeleted
                
                node.next = nil
                node.previous = nil
                
            }
            else
            {
                
                print("Delete head [\(node.tag)]")
                head = nil
                tail = nil
                
                node.next = nil
                node.previous = nil
                
            }
            
        } // end remove head
            
        // Remove the tail?
        else if node.next == nil {
            
            if let deletedPreviousNode = node.previous {
                
                print("Delete tail [\(node.tag)] with predecessors")
                deletedPreviousNode.next = nil
                tail?.previous = nil
                tail = nil
                node.next = nil
                tail = deletedPreviousNode
                
                node.next = nil
                node.previous = nil
                
            }
            else {
                
                print("Delete tail [\(node.tag)]")
                head = nil
                tail = nil
                
                node.next = nil
                node.previous = nil
                
            }
            
        } // end remove tail
            
        // Remove node BETWEEN head and tail?
        else {
            
            if let deletedPreviousNode = node.previous,
                let deletedNextNode = node.next {
                
                node.next = nil
                node.previous = nil
                print("Delete internal node: [\(node.tag)]")
                
                deletedPreviousNode.next = deletedNextNode
                deletedNextNode.previous = deletedPreviousNode
                
            }
            
        } // end remove in-between node
        
    } // end func delete
    
    func showAll() {
        
        print("\n-------------------------")
        print("Printing list:\n")
        
        var nextNode: Node<AnyType>?
        
        if let head = head {
            
            nextNode = head
            
            repeat {
                
                if let tag = nextNode?.tag {
                    print("[\(tag)]")
                }
                    
                nextNode = nextNode?.next
                
            } while (nextNode != nil)
            
        } // end if let head = head
        
        print("-------------------------\n")
        
    } // end func showAll()
    
    func showAllInReverse()
    {
        
        print("\n-------------------------")
        print("Printing list in reverse:\n")
        
        var previousNode: Node<AnyType>?
        
        if let tail = tail {
            
            previousNode = tail
            
            repeat {
                
                if let tag = previousNode?.tag {
                    print("[\(tag)]")
                }
                
                previousNode = previousNode?.previous
                
            } while (previousNode != nil)
        }
        print("-------------------------\n")
        
    } // end func showAllInReverse()
    
    subscript(tag: String) -> Node<AnyType>? {
        
        if head == nil {
            return nil
        }
            
        else {
            
            var currentNode = head
            
            while currentNode != nil {
                
                if tag == currentNode?.tag {
                    return currentNode
                }
                else {
                    currentNode = currentNode?.next
                }
                
            } // end while
            
            return nil
            
        } // end else
        
    } // end subscript
    
    // Unlink all nodes so there are no
    // strong references to prevent
    // deallocation.
    func prepareForDealloc() {
        
        var currentNode: Node<AnyType>?
        
        if var tail = tail {
            
            currentNode = tail
            
            repeat {
                
                if let tag = currentNode?.tag {
                    //print("\(tag)")
                }
                
                tail = currentNode!
                currentNode = currentNode?.previous
                tail.previous = nil
                tail.next = nil
                
            } while (currentNode != nil) // nil is head
            
        } // end if var tail = tail
        
    } // end func showAllInReverse(
    
} // end extension LinkedListProtocol

class LinkedList<AnyType> : LinkedListProtocol {
    
    var head: Node<AnyType>?
    var tail: Node<AnyType>?
    
    init() {
        head = nil
        tail = head
        print("Allocating linked list")
    }
    
    deinit {
        prepareForDealloc()
        head = nil
        tail = nil
        print("Deallocating linked list")
    }
    
} // end class LinkedList

class UIControlList: LinkedList<UIControl> {
    
    func shouldEnable(_ yesOrNo: Bool) {

        if head == nil {
            return
        }
            
        else {
            
            var currentNode = head
            
            while currentNode != nil {
                
                currentNode?.payload?.isEnabled = yesOrNo
                currentNode = currentNode?.next
                
            }
            
        } // end else

    } // end func shouldEnable()
    
    func showAll() {
        
        print("\n-------------------------")
        print("Printing list:\n")
        
        var nextNode: Node<AnyType>?
        
        if let head = head {
            
            nextNode = head
            
            repeat {
                
                if let tag = nextNode?.tag {
                    print("[\(tag)]'s status is \(nextNode?.payload?.isEnabled)")
                }
                
                nextNode = nextNode?.next
                
            } while (nextNode != nil)
            
        } // end if let head = head
        
        print("-------------------------\n")
        
    } // end func showAll()
    
} // end class UIControlList

/*
// declare a linked list of type UIView
// and initialize it
var linkedList = LinkedList<UIView>()

// create some nodes to be added to my list,
// initializing each with a UIVIew and tag/name
let node1 = Node(with: UIView(), named: "View 1")
let node2 = Node(with: UIView(), named: "View 2")
let node3 = Node(with: UIView(), named: "View 3")

// configure one of the UIView's in a node to
// be displayed on screen
let frame = CGRect(x: 100, y: 200, width: 200, height: 20)
let view = UIView(frame: frame)
view.backgroundColor = UIColor.red
let node4 = Node(with: view, named: "View 4")

let node5 = Node(with: UIView(), named: "View 5")

// add the nodes to my linked list
linkedList.append(node1)
linkedList.append(node2)
linkedList.append(node3)
linkedList.append(node4)
linkedList.append(node5)

// print the list to console
linkedList.showAll()

if let nada = linkedList.View6
{
    print("View6 is a Node: \(nada)")
}
else
{
    print("View6 is NOT a Node")
}

// use the "subscript" to get the view
// I configured for display out of my list
let findView4 = linkedList.View4 // Node<__C.UIView>
_ = findView4?.tag // "View 4"
_ = findView4?.payload?.backgroundColor // r 1.0 g 0.0 b 0.0 a 1.0

// experiment with new subscript
_ = linkedList.View1?.tag // "View 1"
_ = linkedList.View2?.payload // UIView
_ = linkedList.View3?.tag // "View 3"
_ = linkedList.View4?.tag // "View 4"
_ = linkedList.View5?.tag // "View 5"
_ = linkedList.View6 // nil and no crash

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        // display my "View 4" UIView on screen
        view.addSubview((findView4?.payload)!)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
*/
/*
do {
    
    print("in local scope")
    // declare a linked list of type UIView
    // and initialize it
    var linkedList = LinkedList<Double>()
    
    // create some nodes to be added to my list,
    // initializing each with a UIVIew and tag/name
    let node1 = Node(with: 1.0, named: "Double 1.0")
    let node2 = Node(with: 2.0, named: "Double 2.0")
    let node2_2 = Node(with: 2.2, named: "Double 2.2")
    let node3 = Node(with: 3.0, named: "Double 3.0")
    let node4 = Node(with: 4.0, named: "Double 4.0")
    let node5 = Node(with: 5.0, named: "Double 5.0")

    // add the nodes to my linked list
    linkedList.append(node1)
    linkedList.delete(node1)
    linkedList.append(node2)
    linkedList.append(node3)
    linkedList.insert(node2_2, after: "Double 2.0")
    linkedList.append(node4)
    linkedList.append(node5)
    
    // test the subscript
    linkedList["Double 3.0"]?.tag
    // "Double 3.0"
    
    // print the list to console
    linkedList.showAll()
    
    // print the list to console in reverse
    linkedList.showAllInReverse()

    // delete nodes in random order
    linkedList.delete(node3)
    linkedList.delete(node1)
    linkedList.delete(node2_2)
    linkedList.delete(node4)
    linkedList.delete(node5)
    linkedList.delete(node2)
    
    // show empty list
    linkedList.showAll()
    
}
*/
/*
do
{
    let node_1_1 = Node(with: UIView(), named: "View 1.1")
    
    do
    {
        var linkedList: LinkedList<UIView> = LinkedList()
        
        let node1 = Node(with: UIView(), named: "View 1")
        let node2 = Node(with: UIView(), named: "View 2")
        
        linkedList.append(node1)
        linkedList.insert(node_1_1, after: "View 1")
        linkedList.append(node2)
        
        linkedList.showAll()
    }
}

var value:Double?
value = 10.0

if var theValue = value
{
    print("The optional variable is NOT nil: \(theValue).")
}
else
{
    print("The optional variable is nil: \(value).")
}

"A" < "b"
"z" < "C"
"View 2" < "View 2.2"
"View 2.2" < "View 3"

//--------------------------------------------------------------
protocol NodeProtocol1
{
    var tag: String? { get }
    var payload: UIView? { get set }
    var next: Self? { get set }
    var previous: Self? { get set }
    
    init(with payload: UIView, named tag: String)
}

class Node1//: NodeProtocol
{
    var tag: String?
    var payload: UIView?
    var next: Node1?
    var previous: Node1?
    
    required init(with payload: UIView, named tag: String)
    {
        self.payload = payload
        self.tag = tag
    }
    
    deinit
    {
        print("Deallocating node tagged: \(tag!)")
    }
}
*/

do {
    
    // Instantiate various UIControls.
    let textField : UITextField = UITextField()
    let slider : UISlider = UISlider()
    let segmented : UISegmentedControl = UISegmentedControl()
    let stepper: UIStepper = UIStepper()
    let button: UIButton = UIButton()
    
    // Create a linked list of type UIControl.
    var uiControlList = UIControlList()
    
    // Append and insert various UIControl descendents as
    // nodes to linked list, giving each a meaningful tag.
    uiControlList.append(Node(with: textField, named: "text field"))
    uiControlList.append(Node(with: slider, named: "slider"))
    uiControlList.append(Node(with: segmented, named: "segmented"))
    uiControlList.insert(Node(with: button, named: "button"), after: "slider")
    uiControlList.append(Node(with: stepper, named: "stepper"))
    
    // Manipulate UIControl descendents using subscript.
    uiControlList["slider"]?.payload?.isEnabled = true
    uiControlList["stepper"]?.payload?.frame // "Show Result"
    uiControlList["text field"]?.payload?.textInputMode
    uiControlList["segmented"]?.payload?.setNeedsDisplay()
    
    // Use feature available to all UIControls.
    uiControlList.shouldEnable(true)
    
    // Print tags of all nodes in linked list
    // in their current ordering from "head" to
    // "tail."
    uiControlList.showAll()
    
}

/*
do {

    // Instantiate various UIControls.
    let textField : UITextField = UITextField()
    let slider : UISlider = UISlider()
    let segmented : UISegmentedControl = UISegmentedControl()
    let stepper: UIStepper = UIStepper()
    let button: UIButton = UIButton()

    // Create a linked list of type UIControl.
    var uiControlList = LinkedList<UIControl>()
    
    // Append and insert various UIControl descendents as
    // nodes to linked list, giving each a meaningful tag.
    uiControlList.append(Node(with: textField, named: "text field"))
    uiControlList.append(Node(with: slider, named: "slider"))
    uiControlList.append(Node(with: segmented, named: "segmented"))
    uiControlList.insert(Node(with: button, named: "button"), after: "slider")
    uiControlList.append(Node(with: stepper, named: "stepper"))
    
    // Manipulate UIControl descendents using subscript.
    uiControlList["slider"]?.payload?.isEnabled = true
    uiControlList["stepper"]?.payload?.frame // "Show Result"
    uiControlList["text field"]?.payload?.textInputMode
    uiControlList["segmented"]?.payload?.setNeedsDisplay()
    
    // Print tags of all nodes in linked list
    // in their current ordering from "head" to
    // "tail."
    uiControlList.showAll()
    
}


struct Point {
    
    let x: Int
    let y: Int
    
}

do {
    
    var point: Point?
    
    var pointList = LinkedList<Point>()
    
    let point1 = Point(x: 1, y: 1)
    let point2 = Point(x: 2, y: 2)
    let point3 = Point(x: 3, y: 3)
    
    let node1 = Node(with: point1, named: "point1")
    let node2 = Node(with: point2, named: "point2")
    let node3 = Node(with: point3, named: "point3")
    
    pointList.append(node1)
    pointList.insert(node2, after: "point1")
    pointList.append(node3)
    
    pointList.showAllInReverse()
    
    pointList.delete(node1)
    
}

*/
