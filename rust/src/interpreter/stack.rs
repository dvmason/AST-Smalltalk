use super::*;
pub fn dup(thread:&mut Thread,_:Object) -> FunctionResult {
    thread.push(thread.top());
    NormalReturn
}
pub fn drop(thread:&mut Thread,_:Object) -> FunctionResult {
    thread.pop_to(thread.offset(1));
    NormalReturn
}
pub fn constant(thread:&mut Thread,object:Object) -> FunctionResult {
    thread.push(object);
    NormalReturn
}
pub fn eq_constant(thread:&mut Thread,object:Object) -> FunctionResult {
    if thread.pop()==object {
        thread.push(trueObject)
    } else {
        thread.push(falseObject)
    }
    NormalReturn
}
pub fn br_true(thread:&mut Thread,object:Object) -> FunctionResult {
    if thread.pop()==trueObject {
        Branch(object.as_i48() as isize)
    } else {
        NormalReturn
    }
}
pub fn nop(thread:&mut Thread,_:Object) -> FunctionResult {
    NormalReturn
}
pub fn add(thread:&mut Thread,_:Object) -> FunctionResult {
    primitives::smallInteger::add(thread,None)
}
pub fn restack(thread:&mut Thread,fields:Object) -> FunctionResult {
    let mut fields = fields.as_u48() as usize;
    let discard = fields&255;
    let mut keep = Vec::new();
    fields = fields>>8;
    while fields>0 {
        keep.push(thread.atOffset(fields&31));
        fields = fields >> 5
    }
    thread.discard(discard);
    thread.append(&mut keep);
    NormalReturn
}
#[cfg(test)]
mod testMethod {
    use super::*;
    use crate::symbol::intern;
    #[test]
    fn restack_mask() {
        assert_eq!(restack_mask!(10=>3,1,5),Object::from((5<<18)|(1<<13)|(3<<8)|10));
    }
    #[test]
    fn noop() {
        let mut thread:Thread = Default::default();
        thread.push(Object::from(42));
        let mut method = Method::new(classObject as u16,0,0,intern("yourself").immediateHash());
        method.instr(stack::nop);
        assert_eq!(method.execute(&mut thread),NormalReturn);
        assert_eq!(thread.top(),Object::from(42));
    }
    #[test]
    fn addSmallInt() {
        let mut thread:Thread = Default::default();
        thread.push_i48(25);
        thread.push_i48(17);
        let mut method = Method::new(classSmallInteger as u16,2,0,intern("+").immediateHash());
        method.instr(stack::add);
        assert_eq!(method.execute(&mut thread),NormalReturn);
        assert_eq!(thread.top().as_i48(),42);
    }
    #[test]
    fn stackManipulation() {
        let mut thread:Thread = Default::default();
        for i in 1..6 {
            thread.push_i48(i);
        }
        let mut method = Method::new(classSmallInteger as u16,2,0,intern("foo").immediateHash());
        method.instr(stack::dup);
        method.instr_i48(stack::constant,3);
        method.instr(stack::add);
        method.instr_with(stack::restack,restack_mask!(5=>1,3,4));
        assert_eq!(method.execute(&mut thread),NormalReturn);
        assert_eq!(thread.pop().as_i48(),3);
        assert_eq!(thread.pop().as_i48(),4);
        assert_eq!(thread.pop().as_i48(),8);
        assert_eq!(thread.pop().as_i48(),1);
    }
}
